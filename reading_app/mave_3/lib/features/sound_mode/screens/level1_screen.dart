import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_providers.dart';
import '../providers/sound_mode_provider.dart';
import '../widgets/mave_next_button.dart';

class Level1Screen extends ConsumerStatefulWidget {
  const Level1Screen({super.key, required this.syllable, required this.onNext});

  final String       syllable;
  final VoidCallback onNext;

  @override
  ConsumerState<Level1Screen> createState() => _Level1ScreenState();
}

class _Level1ScreenState extends ConsumerState<Level1Screen>
    with TickerProviderStateMixin {
  final SpeechToText _stt = SpeechToText();
  bool _listening   = false;
  bool _celebrated  = false;
  String _recognized = '';

  late final AnimationController _bgController;
  late final AnimationController _micPulseController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _micPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _stt.stop();
    _bgController.dispose();
    _micPulseController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    await ref.read(soundModeProvider.notifier).playIntroSequence();
    if (!mounted) return;
    _startListening();
  }

  Future<void> _startListening() async {
    final available = await _stt.initialize();
    if (!available || !mounted) return;
    setState(() => _listening = true);
    _stt.listen(
      listenFor: const Duration(seconds: 12),
      pauseFor:  const Duration(seconds: 4),
      onResult: (result) {
        if (result.hasConfidenceRating && !_celebrated) {
          _recognized = result.recognizedWords;
          _onVocalization();
        }
      },
      onSoundLevelChange: (level) {
        if (level > -20 && !_celebrated) _onVocalization();
      },
    );
  }

  void _onVocalization() {
    if (_celebrated) return;
    setState(() { _celebrated = true; _listening = false; });
    _stt.stop();
    ref.read(soundModeProvider.notifier).recordVocalization(_recognized);
    ref.read(soundModeProvider.notifier).markLevelComplete();
  }

  @override
  Widget build(BuildContext context) {
    final state     = ref.watch(soundModeProvider);
    final phase     = state.playingPhase;
    final audioReady= state.audioReady;
    final consonant = widget.syllable[0].toUpperCase();
    final vowel     = widget.syllable.length > 1 ? widget.syllable[1].toUpperCase() : '';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (ctx, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(math.sin(_bgController.value * math.pi * 2) * 0.3, -1),
                  end:   const Alignment(0, 1),
                  colors: const [Color(0xFF1A1A4E), Color(0xFF533483), Color(0xFF0F3460)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const Spacer(flex: 2),

                    // Main phoneme card
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 36),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color:        Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(48),
                          border:       Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color:      const Color(0xFFFF6B6B).withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _PhonemeDisplay(
                                  letter: consonant,
                                  active: phase == PlayingPhase.consonant || phase == PlayingPhase.full,
                                  activeColor: AppColors.primary,
                                ),
                                if (vowel.isNotEmpty)
                                  _PhonemeDisplay(
                                    letter: vowel,
                                    active: phase == PlayingPhase.vowel || phase == PlayingPhase.full,
                                    activeColor: AppColors.secondary,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _phaseLabel(phase, widget.syllable),
                                key: ValueKey(phase),
                                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).scale(
                        begin: const Offset(0.85, 0.85),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Replay button
                    GestureDetector(
                      onTap: () => ref.read(soundModeProvider.notifier).playIntroSequence(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color:        Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border:       Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.replay_rounded, color: Colors.white70, size: 24),
                            SizedBox(width: 8),
                            Text('Tap to hear again', style: TextStyle(color: Colors.white70, fontSize: 15)),
                          ],
                        ),
                      ),
                    ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),

                    const Spacer(flex: 2),

                    // Listening / celebration UI
                    if (_listening && !_celebrated)
                      _MicWidget(pulseController: _micPulseController),

                    if (_celebrated)
                      _CelebrationWidget(),

                    const Spacer(),
                  ],
                ),

                if (audioReady)
                  Positioned(
                    bottom: 24, right: 24,
                    child: MaveNextButton(onTap: widget.onNext),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(PlayingPhase phase, String syllable) {
    final c = syllable[0];
    final v = syllable.length > 1 ? syllable[1] : syllable[0];
    return switch (phase) {
      PlayingPhase.full     => '"${c * 2}${v * 3}"',
      PlayingPhase.consonant=> '"${c * 2}"',
      PlayingPhase.vowel    => '"${v * 3}"',
      PlayingPhase.idle     => 'Tap to hear it again!',
    };
  }
}

class _PhonemeDisplay extends StatelessWidget {
  const _PhonemeDisplay({required this.letter, required this.active, required this.activeColor});

  final String letter;
  final bool   active;
  final Color  activeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale:    active ? 1.22 : 1.0,
      duration: const Duration(milliseconds: 400),
      curve:    Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          letter,
          style: TextStyle(
            fontSize:   100,
            fontWeight: FontWeight.w900,
            color:      active ? activeColor : Colors.white.withOpacity(0.25),
            shadows: active
                ? [Shadow(color: activeColor.withOpacity(0.6), blurRadius: 24, offset: const Offset(0, 4))]
                : null,
          ),
        ),
      ),
    );
  }
}

class _MicWidget extends StatelessWidget {
  const _MicWidget({required this.pulseController});
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: pulseController,
          builder: (ctx, child) => Transform.scale(
            scale: 0.9 + 0.1 * pulseController.value,
            child: child,
          ),
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(0.2),
              border: Border.all(color: AppColors.secondary, width: 3),
            ),
            child: const Icon(Icons.mic, size: 40, color: AppColors.secondary),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Now you try!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white70)),
      ],
    );
  }
}

class _CelebrationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Amazing!',
      style: TextStyle(
        fontSize:   36,
        fontWeight: FontWeight.w900,
        color:      AppColors.accentGreen,
        shadows: [Shadow(color: Color(0x886BCB77), blurRadius: 16)],
      ),
    )
        .animate()
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut)
        .fadeIn();
  }
}
