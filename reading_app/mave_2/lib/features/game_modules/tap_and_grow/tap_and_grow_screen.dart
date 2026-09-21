import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Tap & Grow — sustain a vocalization to grow a sunflower.
///
/// The flower grows from seedling to full bloom as the child speaks.
/// Accuracy = speaking ticks / total ticks, clamped 0–1.
class TapAndGrowScreen extends ConsumerStatefulWidget {
  const TapAndGrowScreen({
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
  ConsumerState<TapAndGrowScreen> createState() => _TapAndGrowScreenState();
}

class _TapAndGrowScreenState extends ConsumerState<TapAndGrowScreen>
    with SingleTickerProviderStateMixin {
  // ── Growth state ───────────────────────────────────────────────────────────

  double _growthProgress = 0.0; // 0.0 → 1.0
  bool   _complete       = false;

  int _totalTicks    = 0;
  int _speakingTicks = 0;

  Timer? _growthTimer;

  static const double _stepPerTick = 0.009; // ~5.5 s of sustained sound

  // ── Animation ──────────────────────────────────────────────────────────────

  late final AnimationController _swayController;

  // Cached so dispose() can call stop() without using ref.
  late final MicrophoneController _mic;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);

    _swayController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _growthTimer?.cancel();
    _swayController.dispose();
    _mic.stop();
    super.dispose();
  }

  // ── Session ────────────────────────────────────────────────────────────────

  Future<void> _startSession() async {
    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider)
          .speak('Say $phonetic to grow the flower!');
    } catch (_) {}

    if (!mounted) return;
    await _mic.start();
    _startGrowthTimer();
  }

  void _startGrowthTimer() {
    _growthTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted || _complete) { t.cancel(); return; }

      _totalTicks++;

      if (_mic.isSpeaking) {
        _speakingTicks++;
        final newGrowth = (_growthProgress + _stepPerTick).clamp(0.0, 1.0);
        setState(() => _growthProgress = newGrowth);
        if (_growthProgress >= 1.0) {
          t.cancel();
          _onComplete();
        }
      }
    });
  }

  Future<void> _onComplete() async {
    final accuracy = _totalTicks == 0
        ? 0.0
        : (_speakingTicks / _totalTicks).clamp(0.0, 1.0);

    setState(() => _complete = true);
    _mic.stop();

    final levelNotifier = ref.read(levelProvider.notifier);
    final audio = ref.read(audioServiceProvider);

    await levelNotifier.record(widget.activityId, accuracy);
    if (!mounted) return;

    try {
      await audio.speak('Beautiful! Your flower bloomed!');
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(progress: _growthProgress, onBack: widget.onExit),

            const SizedBox(height: 8),

            Text(
              _complete
                  ? '🌻 Your flower bloomed!'
                  : 'Say ${PhoneticHelper.toPhonetic(widget.syllable)} to grow the flower!',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 20, color: AppColors.textDark),
            ).animate(key: ValueKey(_complete)).fadeIn(duration: 300.ms),

            const SizedBox(height: 8),

            // Flower visualisation
            Expanded(
              flex: 3,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return _FlowerGrowthWidget(
                    progress:      _growthProgress,
                    isSpeaking:    mic.isSpeaking,
                    swayAnim:      _swayController,
                    complete:      _complete,
                    maxHeight:     constraints.maxHeight * 0.85,
                  );
                },
              ),
            ),

            // Sound level meter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text('Sound level',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium, fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: mic.isListening ? mic.normalizedLevel : 0),
                      duration: const Duration(milliseconds: 80),
                      builder: (ctx, v, child) => LinearProgressIndicator(
                        value: v,
                        minHeight: 18,
                        backgroundColor: Colors.white.withAlpha(180),
                        color: mic.isSpeaking
                            ? AppColors.accentGreen
                            : AppColors.primary.withAlpha(160),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mic.isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                    color: mic.isListening ? AppColors.primary : AppColors.textLight,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mic.isSpeaking
                        ? 'Growing! Keep going!'
                        : 'Make a sound to grow!',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: mic.isSpeaking
                            ? AppColors.accentGreen
                            : AppColors.textMedium),
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

// ── Flower growth widget ───────────────────────────────────────────────────────

class _FlowerGrowthWidget extends StatelessWidget {
  const _FlowerGrowthWidget({
    required this.progress,
    required this.isSpeaking,
    required this.swayAnim,
    required this.complete,
    required this.maxHeight,
  });

  final double              progress;
  final bool                isSpeaking;
  final AnimationController swayAnim;
  final bool                complete;
  final double              maxHeight;

  @override
  Widget build(BuildContext context) {
    final stemHeight  = maxHeight * progress;
    final showFlower  = progress > 0.6;
    final flowerScale = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: swayAnim,
      builder: (ctx, child) {
        final sway = isSpeaking
            ? math.sin(swayAnim.value * math.pi * 2) * 4.0
            : 0.0;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Soil
            Container(
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 80),
              decoration: BoxDecoration(
                color: const Color(0xFF795548),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Stem
            Transform.translate(
              offset: Offset(sway, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 60),
                width: 8,
                height: stemHeight,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Flower head
            if (showFlower)
              Positioned(
                bottom: stemHeight + 8,
                child: Transform.translate(
                  offset: Offset(sway, 0),
                  child: Transform.scale(
                    scale: flowerScale,
                    child: complete
                        ? const Text('🌻',
                            style: TextStyle(fontSize: 72))
                                .animate()
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.0, 1.0),
                                  duration: 400.ms,
                                  curve: Curves.elasticOut,
                                )
                        : const Text('🌼',
                            style: TextStyle(fontSize: 64)),
                  ),
                ),
              ),

            // Seedling emoji when tiny
            if (progress < 0.15)
              Positioned(
                bottom: 28,
                child: const Text('🌱',
                    style: TextStyle(fontSize: 32)),
              ),
          ],
        );
      },
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                          color: AppColors.textMedium)),
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
                  backgroundColor: Colors.green.withAlpha(60),
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
