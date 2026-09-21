import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/app_providers.dart';
import '../providers/sound_mode_provider.dart';
import '../widgets/bubble_background_painter.dart';
import '../widgets/mave_next_button.dart';

class Level1Screen extends ConsumerStatefulWidget {
  const Level1Screen({super.key, required this.syllable, required this.onNext});

  final String syllable;
  final VoidCallback onNext;

  @override
  ConsumerState<Level1Screen> createState() => _Level1ScreenState();
}

class _Level1ScreenState extends ConsumerState<Level1Screen> {
  final SpeechToText _stt = SpeechToText();
  bool _listening = false;
  bool _celebrated = false; // toddler made a sound → show star

  /// Most recently recognised words from STT — passed to the notifier so
  /// it can score vocalization quality before triggering praise.
  String _recognizedWords = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }

  Future<void> _start() async {
    // Play the intro sequence once (sets audioReady = true when done).
    await ref.read(soundModeProvider.notifier).playIntroSequence();
    if (!mounted) return;

    // Start listening for any toddler vocalization.
    _startListening();
  }

  Future<void> _startListening() async {
    final available = await _stt.initialize();
    if (!available || !mounted) return;
    setState(() => _listening = true);
    _stt.listen(
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        if (result.hasConfidenceRating && !_celebrated) {
          // Capture the STT text so the notifier can score pronunciation quality.
          _recognizedWords = result.recognizedWords;
          _onVocalization();
        }
      },
      onSoundLevelChange: (level) {
        // Sound-level trigger: no recognized text yet; pass empty string so
        // the notifier still speaks a praise phrase (any attempt is rewarded).
        if (level > -20 && !_celebrated) _onVocalization();
      },
    );
  }

  void _onVocalization() {
    if (_celebrated) return;
    setState(() {
      _celebrated = true;
      _listening = false;
    });
    _stt.stop();
    // Score the vocalization and trigger a calibrated praise response.
    // recordVocalization speaks the praise phrase internally — no duplicate
    // speak() call here.
    ref.read(soundModeProvider.notifier).recordVocalization(_recognizedWords);
    ref.read(soundModeProvider.notifier).markLevelComplete();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soundModeProvider);
    final phase = state.playingPhase;
    final audioReady = state.audioReady;
    final syllable = widget.syllable;

    // Split syllable into individual character spans for per-letter animation.
    final consonant = syllable[0].toUpperCase();
    final vowel = syllable.length > 1 ? syllable[1].toUpperCase() : '';

    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Main content ───────────────────────────────────────────────
              Column(
                children: [
              const Spacer(flex: 2),

              // ── Big rounded card ──────────────────────────────────────────
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(48),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 40,
                      spreadRadius: 4,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Per-letter display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PhonemeDisplay(
                          letter: consonant,
                          active: phase == PlayingPhase.consonant ||
                              phase == PlayingPhase.full,
                          activeColor: AppColors.primary,
                        ),
                        if (vowel.isNotEmpty)
                          _PhonemeDisplay(
                            letter: vowel,
                            active: phase == PlayingPhase.vowel ||
                                phase == PlayingPhase.full,
                            activeColor: AppColors.secondary,
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Phase label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _phaseLabel(phase, syllable),
                        key: ValueKey(phase),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMedium,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Tap-to-replay hint ────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  ref.read(soundModeProvider.notifier).playIntroSequence();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(60),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.replay_rounded,
                          color: AppColors.primary, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to hear again',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),

              const Spacer(flex: 2),

              // ── Listening / celebration indicators ───────────────────────
              if (_listening && !_celebrated)
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(40),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.secondary, width: 3),
                      ),
                      child: const Center(
                        child: Icon(Icons.mic,
                            size: 40, color: AppColors.secondary),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1.08, 1.08),
                          duration: 700.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 12),
                    Text(
                      'Now you try! 🎤',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),

              if (_celebrated)
                Text(
                  '🌟 Amazing! 🌟',
                  style: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.accentGreen),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(),

              const Spacer(flex: 1),
                ],
              ),

              // ── Next button — bottom-right corner ────────────────────────
              if (audioReady)
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: MaveNextButton(onTap: widget.onNext),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _phaseLabel(PlayingPhase phase, String syllable) {
    final c = syllable[0];
    final v = syllable.length > 1 ? syllable[1] : syllable[0];
    switch (phase) {
      case PlayingPhase.full:
        return '"${c * 2}${v * 3}"';
      case PlayingPhase.consonant:
        return '"${c * 2}"';
      case PlayingPhase.vowel:
        return '"${v * 3}"';
      case PlayingPhase.idle:
        return 'Tap to hear it again!';
    }
  }
}

// ── Per-letter animated display ──────────────────────────────────────────────

class _PhonemeDisplay extends StatelessWidget {
  const _PhonemeDisplay({
    required this.letter,
    required this.active,
    required this.activeColor,
  });

  final String letter;
  final bool active;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedScale(
        scale: active ? 1.22 : 1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: Text(
          letter,
          style: AppTextStyles.displayHuge.copyWith(
            fontSize: 110,
            color: active ? activeColor : AppColors.textLight,
            shadows: active
                ? [
                    Shadow(
                      color: activeColor.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
