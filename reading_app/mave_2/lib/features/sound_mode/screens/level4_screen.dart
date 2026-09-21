import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/story_page.dart';
import '../../../core/services/app_providers.dart';
import '../providers/sound_mode_provider.dart';
import '../widgets/bubble_background_painter.dart';
import '../widgets/mave_next_button.dart';

class Level4Screen extends ConsumerStatefulWidget {
  const Level4Screen({super.key, required this.syllable, required this.onFinish});

  final String syllable;
  final VoidCallback onFinish;

  @override
  ConsumerState<Level4Screen> createState() => _Level4ScreenState();
}

class _Level4ScreenState extends ConsumerState<Level4Screen>
    with SingleTickerProviderStateMixin {
  // ── Story data ─────────────────────────────────────────────────────────────
  List<StoryPage> _pages = [];

  // ── Narration ──────────────────────────────────────────────────────────────
  bool _isNarrating = false;
  bool _done        = false;
  int  _currentPage = 0;
  int  _narrationGeneration = 0;

  // ── Mic toggle ─────────────────────────────────────────────────────────────
  /// Whether the child's microphone is active for read-along input.
  bool _micEnabled = false;

  // ── UI ─────────────────────────────────────────────────────────────────────
  late final PageController _pageController;
  late final AnimationController _pulseController;

  // Cached so dispose() can call stop() without using ref.
  late final MicrophoneController _mic;

  // ── Inactivity reminder ────────────────────────────────────────────────────
  Timer? _inactivityTimer;
  static const _inactivityDuration = Duration(seconds: 8);

  // ── Life-cycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    if (_micEnabled) _mic.stop();
    super.dispose();
  }

  // ── Story init ─────────────────────────────────────────────────────────────

  void _onStoryReady(List<StoryPage> pages) {
    if (_pages.isNotEmpty) return;
    setState(() => _pages = List.of(pages));
    _narrateFrom(0);
  }

  // ── Narration ──────────────────────────────────────────────────────────────

  Future<void> _narrateFrom(int startPage) async {
    if (_done || _pages.isEmpty) return;

    final generation = ++_narrationGeneration;
    if (mounted) setState(() => _isNarrating = true);

    final audio = ref.read(audioServiceProvider);

    for (int i = startPage; i < _pages.length; i++) {
      if (!mounted || generation != _narrationGeneration) break;

      setState(() => _currentPage = i);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

      await audio.speak(_pages[i].sentence);
      await audio.waitForCompletion(timeout: const Duration(seconds: 20));
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (!mounted || generation != _narrationGeneration) return;

    setState(() {
      _isNarrating = false;
      _done = true;
    });
    ref.read(soundModeProvider.notifier).markLevelComplete();
    ref.read(soundModeProvider.notifier).markAudioReady();
    _resetInactivityTimer();
  }

  // ── Manual navigation ──────────────────────────────────────────────────────

  Future<void> _goToPage(int page) async {
    if (page < 0 || page >= _pages.length) return;

    _narrationGeneration++;
    await ref.read(audioServiceProvider).stop();

    if (!mounted) return;
    setState(() {
      _isNarrating = false;
      _currentPage = page;
    });

    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted && !_done) _narrateFrom(page);
  }

  // ── Mic toggle ─────────────────────────────────────────────────────────────

  Future<void> _toggleMic() async {
    if (_micEnabled) {
      _mic.stop();
      setState(() => _micEnabled = false);
    } else {
      // Pause narration while child reads aloud.
      _narrationGeneration++;
      await ref.read(audioServiceProvider).stop();
      if (!mounted) return;
      setState(() {
        _isNarrating = false;
        _micEnabled  = true;
      });
      await _mic.start();
    }
  }

  // ── Inactivity reminder ────────────────────────────────────────────────────

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, _onInactivityTimeout);
  }

  void _onInactivityTimeout() {
    if (!mounted) return;
    final audio = ref.read(audioServiceProvider);
    if (!audio.isPlaying) {
      audio.speak("Tap the mic to read along, or press next when ready!");
    }
    _resetInactivityTimer();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final storyPages = ref.watch(soundModeProvider).storyPages;
    final audioReady = ref.watch(soundModeProvider).audioReady;
    final mic        = ref.watch(microphoneControllerProvider);

    if (storyPages.isNotEmpty && _pages.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _onStoryReady(storyPages));
    }

    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Listener(
            onPointerDown: (_) {
              if (_done) _resetInactivityTimer();
            },
            child: Column(
              children: [
                _TitleBar(
                  syllable:    widget.syllable,
                  currentPage: _pages.isEmpty ? 0 : _currentPage + 1,
                  totalPages:  _pages.length,
                ),

                Expanded(
                  child: _pages.isEmpty
                      ? _LoadingView()
                      : _buildBook(context, audioReady, mic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBook(BuildContext context, bool audioReady, mic) {
    final isSpeaking = _micEnabled && (mic?.isSpeaking ?? false);

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Board-book ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(52, 8, 52, 80),
          child: _BoardBook(
            child: _FlipPageView(
              controller:  _pageController,
              itemCount:   _pages.length,
              onPageChanged: (p) {
                if (p != _currentPage) setState(() => _currentPage = p);
              },
              itemBuilder: (_, index) => _StoryPageWidget(
                page:           _pages[index],
                syllable:       widget.syllable,
                isActive:       index == _currentPage && _isNarrating,
                isMicActive:    index == _currentPage && _micEnabled,
                isSpeaking:     index == _currentPage && isSpeaking,
                pulseController: _pulseController,
              ),
            ),
          ),
        ),

        // ── Back arrow ──────────────────────────────────────────────────────
        if (_currentPage > 0)
          Positioned(
            left: 0,
            child: _NavArrow(
              icon:  Icons.chevron_left_rounded,
              onTap: () => _goToPage(_currentPage - 1),
            ),
          ).animate().fadeIn(duration: 250.ms),

        // ── Next arrow ──────────────────────────────────────────────────────
        if (_currentPage < _pages.length - 1)
          Positioned(
            right: 0,
            child: _NavArrow(
              icon:  Icons.chevron_right_rounded,
              onTap: () => _goToPage(_currentPage + 1),
            ),
          ).animate().fadeIn(duration: 250.ms),

        // ── Page dots ───────────────────────────────────────────────────────
        Positioned(
          bottom: 48,
          child: _PageDots(count: _pages.length, current: _currentPage),
        ),

        // ── Mic toggle button (bottom-left) ─────────────────────────────────
        Positioned(
          bottom: 12,
          left: 12,
          child: _MicToggleButton(
            enabled:    _micEnabled,
            isSpeaking: isSpeaking,
            onTap:      _toggleMic,
            pulseAnim:  _pulseController,
          ),
        ),

        // ── Finish / next button (bottom-right) ─────────────────────────────
        if (audioReady)
          Positioned(
            bottom: 12,
            right: 12,
            child: MaveNextButton(onTap: widget.onFinish, isFinish: true),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mic toggle button
// ─────────────────────────────────────────────────────────────────────────────

class _MicToggleButton extends StatelessWidget {
  const _MicToggleButton({
    required this.enabled,
    required this.isSpeaking,
    required this.onTap,
    required this.pulseAnim,
  });

  final bool               enabled;
  final bool               isSpeaking;
  final VoidCallback       onTap;
  final AnimationController pulseAnim;

  @override
  Widget build(BuildContext context) {
    final color = isSpeaking
        ? AppColors.accentGreen
        : enabled
            ? AppColors.primary
            : AppColors.textLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (ctx, child) {
          final scale = isSpeaking ? 1.0 + pulseAnim.value * 0.18 : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width:  64,
          height: 64,
          decoration: BoxDecoration(
            color:  color.withAlpha(enabled ? 220 : 80),
            shape:  BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: enabled
                ? [BoxShadow(color: color.withAlpha(100), blurRadius: 16)]
                : [],
          ),
          child: Icon(
            isSpeaking
                ? Icons.record_voice_over_rounded
                : enabled
                    ? Icons.mic_rounded
                    : Icons.mic_none_rounded,
            color: enabled ? Colors.white : AppColors.textLight,
            size:  30,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Title bar
// ─────────────────────────────────────────────────────────────────────────────

class _TitleBar extends StatelessWidget {
  const _TitleBar({
    required this.syllable,
    required this.currentPage,
    required this.totalPages,
  });
  final String syllable;
  final int    currentPage;
  final int    totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Text('Story Time! 📖', style: AppTextStyles.headlineLarge),
          const Spacer(),
          if (totalPages > 0)
            Text(
              '$currentPage / $totalPages',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMedium),
            ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Opening the story...',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Board-book container
// ─────────────────────────────────────────────────────────────────────────────

class _BoardBook extends StatelessWidget {
  const _BoardBook({required this.child});
  final Widget child;

  static const Color _paperColor = Color(0xFFFFF8E7);
  static const Color _spineColor = Color(0xFFE8D5B0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withAlpha(70),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.brown.withAlpha(45),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          child,
          // Spine accent
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _spineColor.withAlpha(200),
                    _spineColor.withAlpha(60),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Top edge highlight
          Positioned(
            left: 0, right: 0, top: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withAlpha(180), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3-D page-flip PageView
// ─────────────────────────────────────────────────────────────────────────────

class _FlipPageView extends StatelessWidget {
  const _FlipPageView({
    required this.controller,
    required this.itemCount,
    required this.onPageChanged,
    required this.itemBuilder,
  });

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageChanged;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller:    controller,
      physics:       const PageScrollPhysics(),
      itemCount:     itemCount,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, child) {
            double offset = 0.0;
            if (controller.hasClients && controller.position.haveDimensions) {
              offset = ((controller.page ?? index.toDouble()) - index)
                  .clamp(-1.0, 1.0);
            }
            final isExiting = offset < 0;
            final pivot = isExiting
                ? Alignment.centerRight
                : Alignment.centerLeft;
            final angle = offset * pi * 0.45;
            return Transform(
              alignment: pivot,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0018)
                ..rotateY(angle),
              child: child,
            );
          },
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Story page widget — illustration top 55%, text bottom 45%
// ─────────────────────────────────────────────────────────────────────────────

class _StoryPageWidget extends StatelessWidget {
  const _StoryPageWidget({
    required this.page,
    required this.syllable,
    required this.isActive,
    required this.isMicActive,
    required this.isSpeaking,
    required this.pulseController,
  });

  final StoryPage            page;
  final String               syllable;
  final bool                 isActive;
  final bool                 isMicActive;
  final bool                 isSpeaking;
  final AnimationController  pulseController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustration
        Expanded(
          flex: 55,
          child: _IllustrationPanel(imagePath: page.imagePath),
        ),

        Container(height: 1.5, color: const Color(0xFFE8D5B0)),

        // Text + mic indicator
        Expanded(
          flex: 45,
          child: _TextPanel(
            sentence:       page.sentence,
            syllable:       syllable,
            isActive:       isActive,
            isMicActive:    isMicActive,
            isSpeaking:     isSpeaking,
            pulseController: pulseController,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Illustration panel
// ─────────────────────────────────────────────────────────────────────────────

class _IllustrationPanel extends StatelessWidget {
  const _IllustrationPanel({required this.imagePath});
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      // Reserved for future image generation.
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFEBD3), Color(0xFFFFD6B0)],
        ),
      ),
      child: const Center(
        child: Text('📖', style: TextStyle(fontSize: 72)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text panel — sentence with target syllable highlighted in colour
// ─────────────────────────────────────────────────────────────────────────────

class _TextPanel extends StatelessWidget {
  const _TextPanel({
    required this.sentence,
    required this.syllable,
    required this.isActive,
    required this.isMicActive,
    required this.isSpeaking,
    required this.pulseController,
  });

  final String              sentence;
  final String              syllable;
  final bool                isActive;
  final bool                isMicActive;
  final bool                isSpeaking;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = isActive ? (1.0 + pulseController.value * 0.025) : 1.0;
        Color bg = const Color(0xFFFFF8E7);
        if (isSpeaking) {
          bg = AppColors.accentGreen.withAlpha(30 + (pulseController.value * 25).toInt());
        } else if (isMicActive) {
          bg = AppColors.primary.withAlpha(15);
        } else if (isActive) {
          bg = AppColors.accent.withAlpha(35);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: bg,
          child: Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRichText(sentence, syllable, isActive),
                if (isMicActive) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSpeaking
                            ? Icons.record_voice_over_rounded
                            : Icons.mic_rounded,
                        size: 18,
                        color: isSpeaking
                            ? AppColors.accentGreen
                            : AppColors.primary.withAlpha(160),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSpeaking ? 'Great! Keep reading!' : 'Your turn to read!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSpeaking
                              ? AppColors.accentGreen
                              : AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRichText(String text, String syllable, bool active) {
    final pattern = RegExp(RegExp.escape(syllable), caseSensitive: false);
    final spans   = <TextSpan>[];
    int cursor = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text:  text.substring(cursor, match.start),
          style: AppTextStyles.storyText,
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: AppTextStyles.storyText.copyWith(
          color:      AppColors.primary,
          fontWeight: FontWeight.w900,
          decoration: active ? TextDecoration.underline : null,
          decorationColor: AppColors.primary,
        ),
      ));
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(
        text:  text.substring(cursor),
        style: AppTextStyles.storyText,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation arrows
// ─────────────────────────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData     icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 88,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7).withAlpha(230),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 34),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page-dot indicator
// ─────────────────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width:  active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.primaryLight.withAlpha(120),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
