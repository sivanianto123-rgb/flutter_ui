import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

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
  double _growthProgress = 0.0;
  bool   _complete       = false;
  int    _totalTicks     = 0;
  int    _speakingTicks  = 0;
  Timer? _growthTimer;

  static const double _stepPerTick = 0.009;

  late final AnimationController _swayController;
  late final MicrophoneController _mic;

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);
    _swayController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _growthTimer?.cancel();
    _swayController.dispose();
    _mic.stopQuietly();
    super.dispose();
  }

  Future<void> _startSession() async {
    try {
      await ref.read(audioServiceProvider).speak('Say ${PhoneticHelper.toPhonetic(widget.syllable)} to grow the flower!');
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
        if (_growthProgress >= 1.0) { t.cancel(); _onComplete(); }
      }
    });
  }

  Future<void> _onComplete() async {
    final accuracy = _totalTicks == 0 ? 0.0 : (_speakingTicks / _totalTicks).clamp(0.0, 1.0);
    setState(() => _complete = true);
    _mic.stop();
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
    if (!mounted) return;
    try { await ref.read(audioServiceProvider).speak('Beautiful! Your flower bloomed!'); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 2200), () { if (mounted) widget.onComplete(); });
  }

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2E0D), Color(0xFF1A4A1A), Color(0xFF0D3B14)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(progress: _growthProgress, onBack: widget.onExit),
              const SizedBox(height: 8),

              Text(
                _complete
                    ? 'Your flower bloomed!'
                    : 'Say ${PhoneticHelper.toPhonetic(widget.syllable)} to grow the flower!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
              ).animate(key: ValueKey(_complete)).fadeIn(duration: 300.ms),

              const SizedBox(height: 8),

              Expanded(
                flex: 3,
                child: LayoutBuilder(
                  builder: (ctx, constraints) => _FlowerGrowthWidget(
                    progress:   _growthProgress,
                    isSpeaking: mic.isSpeaking,
                    swayAnim:   _swayController,
                    complete:   _complete,
                    maxHeight:  constraints.maxHeight * 0.85,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text('Sound level', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: mic.isListening ? mic.normalizedLevel : 0),
                        duration: const Duration(milliseconds: 80),
                        builder: (ctx, v, _) => LinearProgressIndicator(
                          value: v, minHeight: 18,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: mic.isSpeaking ? AppColors.accentGreen : AppColors.secondary,
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
                      color: mic.isListening ? AppColors.accentGreen : Colors.white30,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mic.isSpeaking ? 'Growing! Keep going!' : 'Make a sound to grow!',
                      style: TextStyle(
                        color: mic.isSpeaking ? AppColors.accentGreen : Colors.white60,
                        fontSize: 14, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Flower Growth Widget ───────────────────────────────────────────────────────

class _FlowerGrowthWidget extends StatelessWidget {
  const _FlowerGrowthWidget({
    required this.progress, required this.isSpeaking, required this.swayAnim,
    required this.complete, required this.maxHeight,
  });

  final double              progress;
  final bool                isSpeaking;
  final AnimationController swayAnim;
  final bool                complete;
  final double              maxHeight;

  @override
  Widget build(BuildContext context) {
    final stemHeight  = maxHeight * progress;
    final showFlower  = progress > 0.5;
    final flowerScale = progress > 0.5 ? ((progress - 0.5) / 0.5).clamp(0.0, 1.0) : 0.0;

    return AnimatedBuilder(
      animation: swayAnim,
      builder: (ctx, child) {
        final sway = isSpeaking ? math.sin(swayAnim.value * math.pi * 2) * 4.0 : 0.0;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Soil
            Positioned(
              bottom: 0,
              child: Container(
                width: 160, height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4E342E), Color(0xFF3E2723)]),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            // Stem
            Positioned(
              bottom: 20,
              child: Transform.translate(
                offset: Offset(sway, 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  width: 10, height: stemHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            // Leaves (appear at 40% growth)
            if (progress > 0.4)
              Positioned(
                bottom: maxHeight * 0.28,
                child: Transform.translate(
                  offset: Offset(sway, 0),
                  child: SizedBox(
                    width: 80, height: 30,
                    child: CustomPaint(painter: _LeavesPainter()),
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
                    child: SizedBox(
                      width: 100, height: 100,
                      child: CustomPaint(painter: _SunflowerPainter(bloomed: complete)),
                    ),
                  ),
                ),
              ),

            // Seedling when tiny
            if (progress < 0.12)
              Positioned(
                bottom: 30,
                child: SizedBox(
                  width: 40, height: 40,
                  child: CustomPaint(painter: _SeedlingPainter()),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Custom Painters ────────────────────────────────────────────────────────────

class _SunflowerPainter extends CustomPainter {
  const _SunflowerPainter({required this.bloomed});
  final bool bloomed;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.42;
    final petalColor = bloomed ? AppColors.accent : const Color(0xFFFFD54F);

    // Petals
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + r * 0.72 * math.cos(angle), cy + r * 0.72 * math.sin(angle)),
          width: r * 0.55, height: r * 0.35,
        ),
        Paint()..color = petalColor,
      );
    }

    // Center
    canvas.drawCircle(Offset(cx, cy), r * 0.42,
        Paint()..color = bloomed ? const Color(0xFF3E2723) : const Color(0xFF795548));

    // Seeds pattern
    final seedPaint = Paint()..color = Colors.white.withOpacity(0.3);
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawCircle(Offset(cx + r * 0.22 * math.cos(angle), cy + r * 0.22 * math.sin(angle)), r * 0.07, seedPaint);
    }

    if (bloomed) {
      // Sparkle on bloom
      final sparklePaint = Paint()..color = Colors.white..strokeWidth = 2;
      for (int i = 0; i < 4; i++) {
        final angle = i * math.pi / 2 + math.pi / 4;
        canvas.drawLine(
          Offset(cx + r * 0.55 * math.cos(angle), cy + r * 0.55 * math.sin(angle)),
          Offset(cx + r * 0.75 * math.cos(angle), cy + r * 0.75 * math.sin(angle)),
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SunflowerPainter old) => old.bloomed != bloomed;
}

class _LeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4CAF50);
    // Left leaf
    final leftPath = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..quadraticBezierTo(size.width * 0.1, 0, 0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.2, size.height, size.width / 2, size.height / 2);
    canvas.drawPath(leftPath, paint);
    // Right leaf
    final rightPath = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..quadraticBezierTo(size.width * 0.9, 0, size.width, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.8, size.height, size.width / 2, size.height / 2);
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SeedlingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    // Stem
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - size.height * 0.55),
        Paint()..color = const Color(0xFF66BB6A)..strokeWidth = 3..strokeCap = StrokeCap.round);
    // Leaf
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 8, cy - size.height * 0.45), width: 20, height: 14),
      Paint()..color = const Color(0xFF4CAF50),
    );
  }

  @override
  bool shouldRepaint(_) => false;
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
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white70),
                  SizedBox(width: 4),
                  Text('Home', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                builder: (ctx, v, _) => LinearProgressIndicator(
                  value: v, minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
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
