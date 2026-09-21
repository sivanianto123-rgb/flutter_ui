import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/level_provider.dart';
import '../../../core/services/app_providers.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Sound Tracing — sustain a vocalization to guide the bee across the screen.
///
/// The bee moves rightward at [_stepPerTick] per 50 ms tick while the mic
/// detects active sound above the dB threshold.  Accuracy = speaking ticks /
/// total ticks, recorded to [LevelNotifier] via [activityId].
class SoundTracingScreen extends ConsumerStatefulWidget {
  const SoundTracingScreen({
    super.key,
    required this.syllable,
    required this.activityId,
    required this.onComplete,
    required this.onExit,
  });

  final String syllable;
  final String activityId;
  final VoidCallback onComplete;
  final VoidCallback onExit;

  @override
  ConsumerState<SoundTracingScreen> createState() =>
      _SoundTracingScreenState();
}

class _SoundTracingScreenState extends ConsumerState<SoundTracingScreen>
    with TickerProviderStateMixin {
  // ── Game state ─────────────────────────────────────────────────────────────

  double _beePosition  = 0.0;
  bool   _complete     = false;

  int _totalTicks    = 0;
  int _speakingTicks = 0;

  Timer? _moveTimer;

  /// 0.007 per 50 ms ≈ 7 seconds of sustained sound to win.
  static const double _stepPerTick = 0.007;

  // ── Animations ─────────────────────────────────────────────────────────────

  late final AnimationController _beeWiggleController;
  late final AnimationController _celebrateController;

  // Cached so dispose() can call stop() without using ref.
  late final MicrophoneController _mic;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);

    _beeWiggleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420))
      ..repeat(reverse: true);

    _celebrateController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _beeWiggleController.dispose();
    _celebrateController.dispose();
    _mic.stop();
    super.dispose();
  }

  // ── Session startup ────────────────────────────────────────────────────────

  Future<void> _startSession() async {
    await _mic.start();
    _startMoveTimer();
  }

  // ── Bee movement ───────────────────────────────────────────────────────────

  void _startMoveTimer() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _complete) {
        timer.cancel();
        return;
      }

      _totalTicks++;

      if (_mic.isSpeaking) {
        _speakingTicks++;
        final newPos = (_beePosition + _stepPerTick).clamp(0.0, 1.0);
        setState(() => _beePosition = newPos);
        if (_beePosition >= 1.0) {
          timer.cancel();
          _onComplete();
        }
      }
    });
  }

  // ── Completion ─────────────────────────────────────────────────────────────

  Future<void> _onComplete() async {
    final accuracy = _totalTicks == 0
        ? 0.0
        : (_speakingTicks / _totalTicks).clamp(0.0, 1.0);

    setState(() => _complete = true);
    _celebrateController.forward();

    final levelNotifier = ref.read(levelProvider.notifier);
    final audio = ref.read(audioServiceProvider);

    await levelNotifier.record(widget.activityId, accuracy);
    
    if (!mounted) return;
    try {
      await audio.speak('Yay! You did it! Amazing!');
    } catch (e) {
      debugPrint('[SoundTracing] Win audio failed: $e');
    }

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(progress: _beePosition, onBack: widget.onExit),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _complete
                    ? '🎉 You flew the bee home!'
                    : 'Keep saying ${widget.syllable.toUpperCase()} to move the bee! 🐝',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 20, color: AppColors.textDark),
              ).animate(key: ValueKey(_complete)).fadeIn(duration: 300.ms),
            ),

            const SizedBox(height: 8),

            Expanded(
              flex: 3,
              child: _BeeTrack(
                position: _beePosition,
                isSpeaking: mic.isSpeaking,
                wiggleAnim: _beeWiggleController,
                complete: _complete,
                celebrateAnim: _celebrateController,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _SoundLevelMeter(
                level: mic.normalizedLevel,
                isSpeaking: mic.isSpeaking,
                listening: mic.isListening,
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mic.isListening
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    color: mic.isListening
                        ? AppColors.primary
                        : AppColors.textLight,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mic.isListening
                        ? (mic.isSpeaking
                            ? 'Hearing you! Keep going!'
                            : 'Listening... make a sound!')
                        : 'Microphone starting...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: mic.isListening
                          ? AppColors.textDark
                          : AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bee track ──────────────────────────────────────────────────────────────────

class _BeeTrack extends StatelessWidget {
  const _BeeTrack({
    required this.position,
    required this.isSpeaking,
    required this.wiggleAnim,
    required this.complete,
    required this.celebrateAnim,
  });

  final double              position;
  final bool                isSpeaking;
  final AnimationController wiggleAnim;
  final bool                complete;
  final AnimationController celebrateAnim;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final trackWidth = constraints.maxWidth - 80;
        final beeX       = 40.0 + trackWidth * position;
        final trackY     = constraints.maxHeight * 0.5;

        return Stack(
          children: [
            Positioned(
              left: 40, right: 40, top: trackY - 3,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(120),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Positioned(
              left: 40, top: trackY - 3,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: position),
                duration: const Duration(milliseconds: 60),
                builder: (ctx, v, child) => Container(
                  width: trackWidth * v,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(180),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20, top: trackY - 26,
              child: const Text('🌸', style: TextStyle(fontSize: 40)),
            ),
            Positioned(
              right: 16, top: trackY - 26,
              child: const Text('🌺', style: TextStyle(fontSize: 40))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.15, 1.15),
                    duration: 900.ms,
                  ),
            ),
            Positioned(
              left: beeX - 24,
              top: trackY - 52,
              child: AnimatedBuilder(
                animation: wiggleAnim,
                builder: (ctx, child) => Transform.translate(
                  offset: Offset(
                    0,
                    isSpeaking
                        ? math.sin(wiggleAnim.value * math.pi * 2) * 6
                        : 0.0,
                  ),
                  child: child,
                ),
                child: complete
                    ? const Text('🐝', style: TextStyle(fontSize: 48))
                        .animate(controller: celebrateAnim)
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.6, 1.6),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                    : const Text('🐝', style: TextStyle(fontSize: 44)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Sound level meter ──────────────────────────────────────────────────────────

class _SoundLevelMeter extends StatelessWidget {
  const _SoundLevelMeter({
    required this.level,
    required this.isSpeaking,
    required this.listening,
  });

  final double level;
  final bool   isSpeaking;
  final bool   listening;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Sound level',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMedium, fontSize: 12)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: listening ? level : 0),
            duration: const Duration(milliseconds: 80),
            builder: (ctx, v, child) => LinearProgressIndicator(
              value: v,
              minHeight: 18,
              backgroundColor: Colors.white.withAlpha(180),
              color: isSpeaking ? AppColors.primary : AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.onBack});
  final double       progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textMedium),
                  const SizedBox(width: 4),
                  Text('Home',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 100),
                builder: (ctx, v, child) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: AppColors.secondary.withAlpha(60),
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
