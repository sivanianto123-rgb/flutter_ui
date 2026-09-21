import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Hi Character',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const CharacterScreen(),
    );
  }
}

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _speechController;
  late AnimationController _rotateController;

  late Animation<double> _waveAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _speechAnimation;
  late Animation<double> _rotateAnimation;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: -0.4, end: 0.5).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -12.0, end: 12.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.08).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _speechController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _speechAnimation = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _speechController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _rotateAnimation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _scheduleBlink();
  }

  Future<void> _scheduleBlink() async {
    while (!_disposed) {
      await Future.delayed(const Duration(seconds: 3));
      if (_disposed) break;
      await _blinkController.forward();
      if (_disposed) break;
      await _blinkController.reverse();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _waveController.dispose();
    _floatController.dispose();
    _blinkController.dispose();
    _speechController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D2B), Color(0xFF1A1A4E), Color(0xFF0D2B4E)],
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: StarfieldPainter(),
              child: const SizedBox.expand(),
            ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _waveAnimation,
                  _floatAnimation,
                  _blinkAnimation,
                  _speechAnimation,
                  _rotateAnimation,
                ]),
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: SizedBox(
                        width: 320,
                        height: 440,
                        child: CustomPaint(
                          painter: CharacterPainter(
                            waveAngle: _waveAnimation.value,
                            blinkScale: _blinkAnimation.value,
                            speechScale: _speechAnimation.value,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                '3D Character',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 18,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Starfield background ─────────────────────────────────────────────────────

class StarfieldPainter extends CustomPainter {
  static final List<_Star> _stars = List.generate(
    80,
    (i) => _Star(
      x: math.sin(i * 73.1) * 0.5 + 0.5,
      y: math.cos(i * 41.7) * 0.5 + 0.5,
      r: (math.sin(i * 13.3) * 0.5 + 0.5) * 2 + 0.5,
      opacity: (math.cos(i * 7.9) * 0.5 + 0.5) * 0.7 + 0.3,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()..color = Color.fromRGBO(255, 255, 255, s.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Star {
  final double x, y, r, opacity;
  const _Star({required this.x, required this.y, required this.r, required this.opacity});
}

// ─── Character painter ────────────────────────────────────────────────────────

class CharacterPainter extends CustomPainter {
  final double waveAngle;
  final double blinkScale;
  final double speechScale;

  const CharacterPainter({
    required this.waveAngle,
    required this.blinkScale,
    required this.speechScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 20;

    _drawFloorShadow(canvas, cx, size.height - 20);
    _drawLegs(canvas, cx, cy);
    _drawBody(canvas, cx, cy);
    _drawRightArmStatic(canvas, cx, cy);
    _drawLeftArmWaving(canvas, cx, cy);
    _drawHead(canvas, cx, cy - 115);
    _drawEyes(canvas, cx, cy - 115);
    _drawNose(canvas, cx, cy - 115);
    _drawMouth(canvas, cx, cy - 115);
    _drawHair(canvas, cx, cy - 115);
    _drawSpeechBubble(canvas, cx + 90, cy - 220);
  }

  void _drawFloorShadow(Canvas canvas, double cx, double bottom) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bottom), width: 130, height: 22),
      Paint()
        ..color = const Color(0x59000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  void _drawLegs(Canvas canvas, double cx, double cy) {
    final legPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
      ).createShader(Rect.fromLTWH(cx - 50, cy + 50, 100, 100));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 45, cy + 55, 34, 90),
        const Radius.circular(17),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 11, cy + 55, 34, 90),
        const Radius.circular(17),
      ),
      legPaint,
    );

    _drawShoe(canvas, cx - 28, cy + 140, flip: false);
    _drawShoe(canvas, cx + 28, cy + 140, flip: true);
  }

  void _drawShoe(Canvas canvas, double cx, double cy, {required bool flip}) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + (flip ? 6 : -6), cy),
        width: 52,
        height: 24,
      ),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: const [Color(0xFF424242), Color(0xFF212121)],
        ).createShader(Rect.fromCenter(
            center: Offset(cx + (flip ? 6 : -6), cy), width: 52, height: 24)),
    );
  }

  void _drawBody(Canvas canvas, double cx, double cy) {
    final bodyRect =
        Rect.fromCenter(center: Offset(cx, cy + 10), width: 120, height: 130);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect.translate(4, 6), const Radius.circular(32)),
      Paint()
        ..color = const Color(0x4D000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(32)),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 1.0,
          colors: const [Color(0xFF42A5F5), Color(0xFF1565C0), Color(0xFF0D47A1)],
        ).createShader(bodyRect),
    );

    // Specular highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 22, cy - 25), width: 40, height: 28),
      Paint()
        ..color = const Color(0x47FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Collar
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 48), width: 60, height: 22),
      Paint()..color = const Color(0xFF1976D2),
    );

    // Shirt buttons
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(cx, cy - 10 + i * 22.0),
        5,
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFF90CAF9), Color(0xFF1565C0)],
          ).createShader(
              Rect.fromCircle(center: Offset(cx, cy - 10 + i * 22.0), radius: 5)),
      );
    }
  }

  void _drawLeftArmWaving(Canvas canvas, double cx, double cy) {
    canvas.save();
    canvas.translate(cx - 60, cy - 35);
    canvas.rotate(waveAngle);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, 0, 28, 72),
        const Radius.circular(14),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42A5F5), Color(0xFF0D47A1)],
        ).createShader(const Rect.fromLTWH(-14, 0, 28, 72)),
    );

    // Hand
    canvas.drawCircle(
      const Offset(0, 86),
      18,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.8,
          colors: const [Color(0xFFFFCCBC), Color(0xFFFF8A65)],
        ).createShader(
            Rect.fromCircle(center: const Offset(0, 86), radius: 18)),
    );

    // Finger hints
    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(
        Offset(i * 8.0, 76),
        5,
        Paint()..color = const Color(0xFFFF8A65),
      );
    }

    canvas.restore();
  }

  void _drawRightArmStatic(Canvas canvas, double cx, double cy) {
    final x = cx + 60;
    final y = cy - 35;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 14, y, 28, 72),
        const Radius.circular(14),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF42A5F5), Color(0xFF0D47A1)],
        ).createShader(Rect.fromLTWH(x - 14, y, 28, 72)),
    );

    canvas.drawCircle(
      Offset(x, y + 86),
      18,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.8,
          colors: const [Color(0xFFFFCCBC), Color(0xFFFF8A65)],
        ).createShader(Rect.fromCircle(center: Offset(x, y + 86), radius: 18)),
    );
  }

  void _drawHead(Canvas canvas, double cx, double cy) {
    final headRect =
        Rect.fromCenter(center: Offset(cx, cy), width: 140, height: 148);

    canvas.drawOval(
      headRect.translate(5, 7),
      Paint()
        ..color = const Color(0x4D000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawOval(
      headRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.85,
          colors: const [Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFFF9800)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(headRect),
    );

    // Primary specular highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 28, cy - 32), width: 42, height: 28),
      Paint()
        ..color = const Color(0x73FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Rim light
    canvas.drawArc(
      headRect.inflate(2),
      math.pi * 0.3,
      math.pi * 0.6,
      false,
      Paint()
        ..color = const Color(0x1FFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _drawEar(canvas, cx - 70, cy + 5);
    _drawEar(canvas, cx + 70, cy + 5);
    _drawBlush(canvas, cx - 38, cy + 18);
    _drawBlush(canvas, cx + 38, cy + 18);
  }

  void _drawEar(Canvas canvas, double x, double y) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 22, height: 30),
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFFFFCC80), Color(0xFFFF9800)],
        ).createShader(
            Rect.fromCenter(center: Offset(x, y), width: 22, height: 30)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 10, height: 16),
      Paint()..color = const Color(0x99FF8A65),
    );
  }

  void _drawBlush(Canvas canvas, double x, double y) {
    canvas.drawCircle(
      Offset(x, y),
      14,
      Paint()
        ..color = const Color(0x40FF80AB)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawHair(Canvas canvas, double cx, double cy) {
    final hairPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.5),
        radius: 1.0,
        colors: const [Color(0xFF5D4037), Color(0xFF3E2723)],
      ).createShader(
          Rect.fromCenter(center: Offset(cx, cy - 60), width: 150, height: 80));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 62), width: 148, height: 68),
      hairPaint,
    );

    final tuftPath = Path()
      ..moveTo(cx - 10, cy - 88)
      ..quadraticBezierTo(cx, cy - 108, cx + 10, cy - 88);
    canvas.drawPath(
      tuftPath,
      Paint()
        ..color = const Color(0xFF4E342E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 72, cy - 35, 12, 30),
        const Radius.circular(6),
      ),
      hairPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 60, cy - 35, 12, 30),
        const Radius.circular(6),
      ),
      hairPaint,
    );
  }

  void _drawEyes(Canvas canvas, double cx, double cy) {
    for (final dx in [-28.0, 28.0]) {
      final eyeCenter = Offset(cx + dx, cy - 5);
      final eyeH = 28.0 * blinkScale;

      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 30, height: eyeH),
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.2, -0.3),
            radius: 0.8,
            colors: const [Colors.white, Color(0xFFE8E8E8)],
          ).createShader(
              Rect.fromCenter(center: eyeCenter, width: 30, height: eyeH)),
      );

      if (blinkScale > 0.25) {
        // Iris
        canvas.drawCircle(
          eyeCenter.translate(2, 0),
          10 * blinkScale,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.2, -0.3),
              colors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
            ).createShader(
                Rect.fromCircle(center: eyeCenter, radius: 10)),
        );

        // Pupil
        canvas.drawCircle(
          eyeCenter.translate(3, 1),
          5 * blinkScale,
          Paint()..color = Colors.black,
        );

        // Shine
        canvas.drawCircle(
          eyeCenter.translate(5, -4),
          3 * blinkScale,
          Paint()..color = const Color(0xE6FFFFFF),
        );

        // Eyelash
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + dx, cy - 5 - eyeH / 2 + 1),
            width: 32,
            height: 6,
          ),
          Paint()..color = const Color(0xFF3E2723),
        );
      }
    }

    // Eyebrows
    for (final dx in [-28.0, 28.0]) {
      final path = Path()
        ..moveTo(cx + dx - 16, cy - 28)
        ..quadraticBezierTo(cx + dx, cy - 34, cx + dx + 16, cy - 28);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF3E2723)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawNose(Canvas canvas, double cx, double cy) {
    final path = Path()
      ..moveTo(cx, cy + 10)
      ..quadraticBezierTo(cx + 6, cy + 24, cx + 12, cy + 26)
      ..quadraticBezierTo(cx, cy + 30, cx - 12, cy + 26)
      ..quadraticBezierTo(cx - 6, cy + 24, cx, cy + 10);

    canvas.drawPath(path, Paint()..color = const Color(0xB3FF8A65));
  }

  void _drawMouth(Canvas canvas, double cx, double cy) {
    final smilePath = Path()
      ..moveTo(cx - 28, cy + 40)
      ..quadraticBezierTo(cx, cy + 62, cx + 28, cy + 40);

    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    final mouthFill = Path()
      ..moveTo(cx - 28, cy + 40)
      ..quadraticBezierTo(cx, cy + 62, cx + 28, cy + 40)
      ..quadraticBezierTo(cx + 16, cy + 52, cx - 16, cy + 52)
      ..close();
    canvas.drawPath(mouthFill, Paint()..color = const Color(0xFFB71C1C));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 18, cy + 40, 36, 12),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white,
    );
  }

  void _drawSpeechBubble(Canvas canvas, double x, double y) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(speechScale, speechScale);
    canvas.translate(-x, -y);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 60, y - 40, 120, 64),
      const Radius.circular(18),
    );

    // Shadow
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Bubble
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Colors.white, Color(0xFFF3F4FF)],
        ).createShader(bubbleRect.outerRect),
    );

    // Border
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..color = const Color(0x807986CB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Tail
    final tail = Path()
      ..moveTo(x - 40, y + 24)
      ..lineTo(x - 60, y + 52)
      ..lineTo(x - 16, y + 24)
      ..close();
    canvas.drawPath(tail, Paint()..color = Colors.white);
    canvas.drawPath(
      tail,
      Paint()
        ..color = const Color(0x807986CB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // "Hi! 👋" text
    final tp = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Hi! ',
            style: TextStyle(
              color: Color(0xFF3949AB),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          TextSpan(text: '\u{1F44B}', style: TextStyle(fontSize: 24)),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2 - 4));

    canvas.restore();
  }

  @override
  bool shouldRepaint(CharacterPainter old) =>
      old.waveAngle != waveAngle ||
      old.blinkScale != blinkScale ||
      old.speechScale != speechScale;
}
