import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/app_providers.dart';
import '../providers/sound_mode_provider.dart';
import '../../game_modules/echo_animal/echo_animal_screen.dart';
import '../../game_modules/feed_the_monster/feed_the_monster_screen.dart';
import '../../game_modules/phoneme_train/phoneme_train_screen.dart';
import '../../game_modules/sound_tracing/sound_tracing_screen.dart';
import '../../game_modules/tap_and_grow/tap_and_grow_screen.dart';
import '../../game_modules/whos_behind_door/whos_behind_door_screen.dart';
import '../../game_modules/word_reading/word_reading_screen.dart';
import 'level1_screen.dart';
import 'level3_screen.dart';
import 'level4_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────

/// 10-level phoneme learning session for a single [syllable].
///
/// Page order:
///   0. Level 1  — phoneme introduction (listen + try)
///   1. Feed the Monster — drag target bubble
///   2. Syllable Pop — tap matching bubbles
///   3. Sound Tracing — bee + microphone
///   4. Echo the Animal — hear animal + echo phoneme
///   5. Tap & Grow — sustain sound to grow flower
///   6. Who's Behind the Door? — audio-visual matching
///   7. Phoneme Train — tap the correct wagon
///   8. Dance Off — rhythm pad game
///   9. Level 4  — storybook finale
///
/// [onFinish] is called when the child completes or exits the last level.
class SoundModeScreen extends ConsumerStatefulWidget {
  const SoundModeScreen({
    super.key,
    required this.syllable,
    required this.onFinish,
  });

  /// Target phoneme, e.g. 'ma' or 'pa'.
  final String syllable;

  /// Called when the session is complete or the child exits.
  final VoidCallback onFinish;

  @override
  ConsumerState<SoundModeScreen> createState() => _SoundModeScreenState();
}

class _SoundModeScreenState extends ConsumerState<SoundModeScreen> {
  static const int _totalPages = 10;

  late final PageController _pageController;
  bool _initialized = false;
  int  _currentPage = 0;

  // Cached to avoid calling ref.read() in dispose().
  late final ValueNotifier<String?> _offlineNotifier;
  VoidCallback? _offlineListener;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onScrollChanged);
    _offlineNotifier = ref.read(audioServiceProvider).offlineModeNotifier;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(soundModeProvider.notifier).initSync(widget.syllable);
      if (mounted) setState(() => _initialized = true);

      ref.read(soundModeProvider.notifier)
          .preloadAudio(widget.syllable)
          .catchError((e) {
        debugPrint('[SoundModeScreen] preload error (non-fatal): $e');
      });

      // Show a one-time SnackBar if TTS goes offline.
      _offlineListener = () {
        final msg = _offlineNotifier.value;
        if (msg != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      };
      _offlineNotifier.addListener(_offlineListener!);
    });
  }

  @override
  void dispose() {
    if (_offlineListener != null) {
      _offlineNotifier.removeListener(_offlineListener!);
    }
    _pageController.removeListener(_onScrollChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) setState(() => _currentPage = page);
  }

  Future<void> _onNext() async {
    ref.read(soundModeProvider.notifier).advanceLevel();
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onSkip() {
    final notifier = ref.read(soundModeProvider.notifier);
    notifier.markAudioReady();
    notifier.markLevelComplete();
    if (_currentPage < _totalPages - 1) {
      _onNext();
    } else {
      widget.onFinish();
    }
  }

  // ── Activity IDs ───────────────────────────────────────────────────────────

  String _activityId(String suffix) => '${widget.syllable}_$suffix';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Level pages ──────────────────────────────────────────────────────
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // ── Page 0: Phoneme intro ────────────────────────────────────────
              Level1Screen(
                syllable: widget.syllable,
                onNext: _onNext,
              ),

              // ── Page 1: Feed the Monster ─────────────────────────────────────
              FeedTheMonsterScreen(
                syllable:   widget.syllable,
                activityId: _activityId('feed_monster'),
                onComplete: _onNext,
                onExit:     widget.onFinish,
              ),

              // ── Page 2: Syllable Pop ─────────────────────────────────────────
              Level3Screen(
                syllable:   widget.syllable,
                activityId: _activityId('syllable_pop'),
                onNext:     _onNext,
              ),

              // ── Page 3: Sound Tracing ────────────────────────────────────────
              SoundTracingScreen(
                syllable:   widget.syllable,
                activityId: _activityId('sound_tracing'),
                onComplete: _onNext,
                onExit:     widget.onFinish,
              ),

              // ── Page 4: Echo the Animal ──────────────────────────────────────
              EchoAnimalScreen(
                syllable:   widget.syllable,
                activityId: _activityId('echo_animal'),
                onComplete: _onNext,
                onExit:     widget.onFinish,
              ),

              // ── Page 5: Tap & Grow ───────────────────────────────────────────
              TapAndGrowScreen(
                syllable:   widget.syllable,
                activityId: _activityId('tap_grow'),
                onComplete: _onNext,
                onExit:     widget.onFinish,
              ),

              // ── Page 6: Who's Behind the Door? ───────────────────────────────
              WhosBehindDoorScreen(
                syllable:   widget.syllable,
                activityId: _activityId('whos_behind_door'),
                onComplete: _onNext,
                onExit:     widget.onFinish,
              ),

              // ── Page 7: Phoneme Train ────────────────────────────────────────
              PhonemeTrainScreen(
                syllable:   widget.syllable,
                activityId: _activityId('phoneme_train'),
                onComplete: _onNext,
                onExit:     widget.onFinish,
              ),

              // ── Page 8: Storybook ────────────────────────────────────────────
              Level4Screen(
                syllable: widget.syllable,
                onFinish: _onNext,
              ),

              // ── Page 9: Word reading ──────────────────────────────────────────
              WordReadingScreen(
                syllable:   widget.syllable,
                activityId: _activityId('word_reading'),
                onComplete: widget.onFinish,
                onExit:     widget.onFinish,
              ),
            ],
          ),

          // ── Top nav bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _NavChip(
                    icon:  Icons.arrow_back_ios_new_rounded,
                    label: 'Home',
                    onTap: widget.onFinish,
                  ),

                  const Spacer(),

                  _StepDots(
                    current: _currentPage,
                    total: _totalPages,
                    onDotTapped: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),

                  const Spacer(),

                  _NavChip(
                    icon:   Icons.skip_next_rounded,
                    label:  isLastPage ? 'Finish' : 'Skip',
                    onTap:  _onSkip,
                    filled: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step dot indicator ────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({
    required this.current,
    required this.total,
    required this.onDotTapped,
  });

  final int current;
  final int total;
  final ValueChanged<int> onDotTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return GestureDetector(
          onTap: () => onDotTapped(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width:  active ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : AppColors.primary.withAlpha(80),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }
}

// ── Shared navigation chip ────────────────────────────────────────────────────

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary.withAlpha(220)
              : Colors.white.withAlpha(180),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!filled) ...[
              Icon(icon, size: 16, color: AppColors.textMedium),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textMedium)),
            ] else ...[
              Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
