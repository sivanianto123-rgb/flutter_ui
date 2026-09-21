import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/providers/app_providers.dart';

// ---------------------------------------------------------------------------
// MaveNPC – programmatic animated blob character
// ---------------------------------------------------------------------------

class MaveNPC extends ConsumerStatefulWidget {
  final double size;
  const MaveNPC({super.key, this.size = 220});

  @override
  ConsumerState<MaveNPC> createState() => _MaveNPCState();
}

class _MaveNPCState extends ConsumerState<MaveNPC>
    with TickerProviderStateMixin {
  // --- Breathing (idle) ---
  late final AnimationController _breathCtrl;
  late final Animation<double> _breathAnim;

  // --- Bounce (happy) ---
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  // --- Mouth pulse (speaking) ---
  late final AnimationController _mouthCtrl;
  late final Animation<double> _mouthAnim;

  // --- Lean (listening) ---
  late final AnimationController _leanCtrl;
  late final Animation<double> _leanAnim;

  // --- Eye gaze target (normalised 0..1) ---
  Offset _gazeTarget = const Offset(0.5, 0.5);

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );

    _mouthCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _mouthAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mouthCtrl, curve: Curves.easeInOut),
    );

    _leanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _leanAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _leanCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _bounceCtrl.dispose();
    _mouthCtrl.dispose();
    _leanCtrl.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceCtrl.forward(from: 0);
  }

  void _applyState(MaveState s) {
    switch (s) {
      case MaveState.idle:
        _leanCtrl.reverse();
        break;
      case MaveState.listening:
        _leanCtrl.forward();
        break;
      case MaveState.speaking:
        _leanCtrl.reverse();
        break;
      case MaveState.happy:
        _triggerBounce();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maveState = ref.watch(maveStateProvider);
    final touch = ref.watch(touchPositionProvider);
    _gazeTarget = Offset(touch.$1, touch.$2);

    // React to state changes
    ref.listen(maveStateProvider, (prev, next) {
      if (prev != next) _applyState(next);
    });

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathAnim,
          _bounceAnim,
          _mouthAnim,
          _leanAnim,
        ]),
        builder: (context, _) {
          final Color bodyColor = switch (maveState) {
            MaveState.happy => AppColors.maveHappy,
            MaveState.listening => AppColors.maveListening,
            MaveState.speaking => AppColors.maveSpeaking,
            MaveState.idle => AppColors.maveIdle,
          };

          // Bounce offset: spring from bottom
          final bounceOffset =
              -30.0 * math.sin(_bounceAnim.value * math.pi).clamp(0.0, 1.0);

          // Lean offset (listening leans forward = slight x)
          final leanX = 8.0 * _leanAnim.value;

          // Mouth open factor
          final mouthOpen =
              maveState == MaveState.speaking ? _mouthAnim.value : 0.3;

          return Transform.translate(
            offset: Offset(leanX, bounceOffset),
            child: Transform.scale(
              scale: maveState == MaveState.idle ? _breathAnim.value : 1.0,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _MavePainter(
                  bodyColor: bodyColor,
                  gazeTarget: _gazeTarget,
                  mouthOpen: mouthOpen,
                  isListening: maveState == MaveState.listening,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter for the blob body + eyes + mouth
// ---------------------------------------------------------------------------

class _MavePainter extends CustomPainter {
  final Color bodyColor;
  final Offset gazeTarget; // normalised 0..1
  final double mouthOpen; // 0..1
  final bool isListening;

  const _MavePainter({
    required this.bodyColor,
    required this.gazeTarget,
    required this.mouthOpen,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    _drawBody(canvas, cx, cy, r);
    _drawEyes(canvas, cx, cy, r);
    _drawMouth(canvas, cx, cy, r);
  }

  void _drawBody(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Blob path: slightly irregular circle built with cubic beziers
    final path = _blobPath(cx, cy + r * 0.04, r);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.18, cy - r * 0.28),
        width: r * 0.5,
        height: r * 0.3,
      ),
      highlightPaint,
    );
  }

  Path _blobPath(double cx, double cy, double r) {
    // 4-point blob with slight squish
    final path = Path();
    const kCtrl = 0.55;
    final rx = r * 0.95;
    final ry = r;

    path.moveTo(cx, cy - ry);
    path.cubicTo(
      cx + kCtrl * rx, cy - ry,
      cx + rx, cy - kCtrl * ry,
      cx + rx, cy,
    );
    path.cubicTo(
      cx + rx, cy + kCtrl * ry,
      cx + kCtrl * rx, cy + ry,
      cx, cy + ry,
    );
    path.cubicTo(
      cx - kCtrl * rx, cy + ry,
      cx - rx, cy + kCtrl * ry,
      cx - rx, cy,
    );
    path.cubicTo(
      cx - rx, cy - kCtrl * ry,
      cx - kCtrl * rx, cy - ry,
      cx, cy - ry,
    );
    path.close();
    return path;
  }

  void _drawEyes(Canvas canvas, double cx, double cy, double r) {
    // Eye socket positions
    final leftCenter = Offset(cx - r * 0.3, cy - r * 0.15);
    final rightCenter = Offset(cx + r * 0.3, cy - r * 0.15);
    final eyeR = r * 0.18;

    // Wide eyes when listening
    final eyeScaleFactor = isListening ? 1.25 : 1.0;

    for (final ec in [leftCenter, rightCenter]) {
      // White sclera
      canvas.drawCircle(
        ec,
        eyeR * eyeScaleFactor,
        Paint()..color = Colors.white,
      );

      // Pupil tracks gaze
      final gazeOffsetX = (gazeTarget.dx - 0.5) * eyeR * 0.6;
      final gazeOffsetY = (gazeTarget.dy - 0.5) * eyeR * 0.6;
      final pupilCenter =
          ec.translate(gazeOffsetX, gazeOffsetY);

      canvas.drawCircle(
        pupilCenter,
        eyeR * 0.55 * eyeScaleFactor,
        Paint()..color = AppColors.maveEye,
      );

      // Pupil shine
      canvas.drawCircle(
        pupilCenter.translate(-eyeR * 0.1, -eyeR * 0.1),
        eyeR * 0.12,
        Paint()..color = Colors.white70,
      );
    }
  }

  void _drawMouth(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..color = AppColors.maveMouth
      ..style = PaintingStyle.fill;

    final mouthWidth = r * 0.5;
    final mouthHeight = r * 0.2 * mouthOpen;
    final mouthY = cy + r * 0.3;

    final path = Path();
    path.moveTo(cx - mouthWidth / 2, mouthY);
    path.quadraticBezierTo(
      cx,
      mouthY + mouthHeight,
      cx + mouthWidth / 2,
      mouthY,
    );
    path.close();
    canvas.drawPath(path, paint);

    // Outline
    final outlinePaint = Paint()
      ..color = AppColors.maveMouth.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(_MavePainter old) =>
      old.bodyColor != bodyColor ||
      old.gazeTarget != gazeTarget ||
      old.mouthOpen != mouthOpen ||
      old.isListening != isListening;
}
