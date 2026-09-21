import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

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
  ConsumerState<SoundTracingScreen> createState() => _SoundTracingScreenState();
}

class _SoundTracingScreenState extends ConsumerState<SoundTracingScreen>
    with TickerProviderStateMixin {
  double _beePosition  = 0.0;
  bool   _complete     = false;
  int    _totalTicks   = 0;
  int    _speakingTicks= 0;
  Timer? _moveTimer;

  static const double _stepPerTick = 0.007;

  late final AnimationController _beeWiggleController;
  late final AnimationController _wingController;
  late final AnimationController _celebrateController;
  late final MicrophoneController _mic;

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);
    _beeWiggleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..repeat(reverse: true);
    _wingController      = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..repeat(reverse: true);
    _celebrateController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _beeWiggleController.dispose();
    _wingController.dispose();
    _celebrateController.dispose();
    _mic.stopQuietly();
    super.dispose();
  }

  Future<void> _startSession() async {
    await _mic.start();
    _startMoveTimer();
  }

  void _startMoveTimer() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _complete) { timer.cancel(); return; }
      _totalTicks++;
      if (_mic.isSpeaking) {
        _speakingTicks++;
        final newPos = (_beePosition + _stepPerTick).clamp(0.0, 1.0);
        setState(() => _beePosition = newPos);
        if (_beePosition >= 1.0) { timer.cancel(); _onComplete(); }
      }
    });
  }

  Future<void> _onComplete() async {
    final accuracy = _totalTicks == 0 ? 0.0 : (_speakingTicks / _totalTicks).clamp(0.0, 1.0);
    setState(() => _complete = true);
    _celebrateController.forward();
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
    if (!mounted) return;
    try { await ref.read(audioServiceProvider).speak('Yay! You flew the bee home!'); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 2200), () { if (mounted) widget.onComplete(); });
  }

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [Color(0xFF0D1B3E), Color(0xFF1A3A6E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(progress: _beePosition, onBack: widget.onExit),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _complete
                      ? 'You flew the bee home!'
                      : 'Keep saying ${PhoneticHelper.toPhonetic(widget.syllable)} to move the bee!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                ).animate(key: ValueKey(_complete)).fadeIn(duration: 300.ms),
              ),

              const SizedBox(height: 8),

              Expanded(
                flex: 3,
                child: _BeeTrack(
                  position:       _beePosition,
                  isSpeaking:     mic.isSpeaking,
                  wiggleAnim:     _beeWiggleController,
                  wingAnim:       _wingController,
                  complete:       _complete,
                  celebrateAnim:  _celebrateController,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _SoundLevelMeter(level: mic.normalizedLevel, isSpeaking: mic.isSpeaking, listening: mic.isListening),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      mic.isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                      color: mic.isListening ? AppColors.secondary : Colors.white30,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mic.isListening
                          ? (mic.isSpeaking ? 'Hearing you! Keep going!' : 'Listening... make a sound!')
                          : 'Microphone starting...',
                      style: TextStyle(
                        fontSize: 14,
                        color: mic.isListening ? Colors.white70 : Colors.white30,
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

// ── Bee track ──────────────────────────────────────────────────────────────────

class _BeeTrack extends StatelessWidget {
  const _BeeTrack({
    required this.position, required this.isSpeaking, required this.wiggleAnim,
    required this.wingAnim, required this.complete, required this.celebrateAnim,
  });

  final double              position;
  final bool                isSpeaking;
  final AnimationController wiggleAnim;
  final AnimationController wingAnim;
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
            // Track background
            Positioned(
              left: 40, right: 40, top: trackY - 3,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // Track progress
            Positioned(
              left: 40, top: trackY - 3,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: position),
                duration: const Duration(milliseconds: 60),
                builder: (ctx, v, _) => Container(
                  width: trackWidth * v, height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.accentGreen]),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.5), blurRadius: 8)],
                  ),
                ),
              ),
            ),
            // Flower at start (CustomPainter)
            Positioned(
              left: 12, top: trackY - 28,
              child: SizedBox(width: 56, height: 56,
                  child: CustomPaint(painter: _FlowerPainter(color: AppColors.accentPurple))),
            ),
            // Honeycomb at end (CustomPainter)
            Positioned(
              right: 12, top: trackY - 28,
              child: SizedBox(width: 56, height: 56,
                  child: CustomPaint(painter: _HoneycombPainter()))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.12, 1.12), duration: 900.ms),
            ),
            // Bee
            Positioned(
              left: beeX - 28,
              top:  trackY - 56,
              child: AnimatedBuilder(
                animation: Listenable.merge([wiggleAnim, wingAnim]),
                builder: (ctx, child) => Transform.translate(
                  offset: Offset(0, isSpeaking ? math.sin(wiggleAnim.value * math.pi * 2) * 6 : 0.0),
                  child: complete
                      ? child!.animate(controller: celebrateAnim)
                          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.6, 1.6), duration: 500.ms, curve: Curves.elasticOut)
                      : child,
                ),
                child: SizedBox(
                  width: 56, height: 56,
                  child: AnimatedBuilder(
                    animation: wingAnim,
                    builder: (_, __) => CustomPaint(painter: _BeePainter(wingFlap: wingAnim.value)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── CustomPainter: Bee ────────────────────────────────────────────────────────

class _BeePainter extends CustomPainter {
  const _BeePainter({required this.wingFlap});
  final double wingFlap;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.6;
    final r  = size.width * 0.32;

    // Wings
    final wingPaint = Paint()..color = Colors.lightBlue.withOpacity(0.5 + wingFlap * 0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.8, cy - r * 0.8), width: r * 1.4, height: r * 0.7), wingPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.8, cy - r * 0.8), width: r * 1.4, height: r * 0.7), wingPaint);

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.3, height: r * 1.8),
        Paint()..color = const Color(0xFFFFE66D));

    // Stripes
    final stripePaint = Paint()..color = const Color(0xFF1A0A0A)..strokeWidth = r * 0.38..strokeCap = StrokeCap.round;
    for (final dy in [-r * 0.25, r * 0.15, r * 0.55]) {
      final half = math.sqrt(math.max(0, r * r * 0.42 - dy * dy));
      canvas.drawLine(Offset(cx - half * 0.9, cy + dy), Offset(cx + half * 0.9, cy + dy), stripePaint);
    }

    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.9), r * 0.5, Paint()..color = const Color(0xFF1A0A0A));
    // Eyes
    canvas.drawCircle(Offset(cx - r * 0.18, cy - r * 1.0), r * 0.12, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 1.0), r * 0.12, Paint()..color = Colors.white);
    // Stinger
    final path = Path()
      ..moveTo(cx, cy + r * 0.9)
      ..lineTo(cx - r * 0.12, cy + r * 0.7)
      ..lineTo(cx + r * 0.12, cy + r * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE6C84A));
  }

  @override
  bool shouldRepaint(_BeePainter old) => old.wingFlap != wingFlap;
}

// ── CustomPainter: Flower ─────────────────────────────────────────────────────

class _FlowerPainter extends CustomPainter {
  const _FlowerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.38;
    final petalPaint = Paint()..color = color.withOpacity(0.85);
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)), width: r * 0.9, height: r * 0.5),
        petalPaint,
      );
    }
    canvas.drawCircle(Offset(cx, cy), r * 0.5, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── CustomPainter: Honeycomb ──────────────────────────────────────────────────

class _HoneycombPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint  = Paint()..color = const Color(0xFFFFBE76);
    final border = Paint()..color = const Color(0xFFE6A020)..style = PaintingStyle.stroke..strokeWidth = 2;
    _hexagon(canvas, Offset(cx, cy), 20, paint, border);
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 6;
      _hexagon(canvas, Offset(cx + 22 * math.cos(angle), cy + 22 * math.sin(angle)), 11, paint, border);
    }
  }

  void _hexagon(Canvas canvas, Offset center, double r, Paint fill, Paint border) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 6;
      final pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Sound level meter ──────────────────────────────────────────────────────────

class _SoundLevelMeter extends StatelessWidget {
  const _SoundLevelMeter({required this.level, required this.isSpeaking, required this.listening});
  final double level;
  final bool   isSpeaking;
  final bool   listening;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Sound level', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: listening ? level : 0),
            duration: const Duration(milliseconds: 80),
            builder: (ctx, v, _) => LinearProgressIndicator(
              value: v, minHeight: 18,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: isSpeaking ? AppColors.accentGreen : AppColors.secondary,
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
