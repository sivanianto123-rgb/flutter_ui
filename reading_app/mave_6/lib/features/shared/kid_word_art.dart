import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Simple painted pictures for toddler word/sentence activities (no emojis).
enum KidPicture {
  bat,
  bag,
  mat,
  map,
  man,
  cat,
  sun,
  ball,
}

class KidWordArt extends StatelessWidget {
  const KidWordArt({
    super.key,
    required this.picture,
    this.size = 120,
    this.bob = 0,
  });

  final KidPicture picture;
  final double size;
  final double bob;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, math.sin(bob * math.pi * 2) * 4),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _KidPicturePainter(picture)),
      ),
    );
  }
}

class _KidPicturePainter extends CustomPainter {
  const _KidPicturePainter(this.picture);
  final KidPicture picture;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    switch (picture) {
      case KidPicture.bat:
        _paintBat(canvas, cx, cy, size.width);
      case KidPicture.bag:
        _paintBag(canvas, cx, cy, size.width);
      case KidPicture.mat:
        _paintMat(canvas, cx, cy, size.width);
      case KidPicture.map:
        _paintMap(canvas, cx, cy, size.width);
      case KidPicture.man:
        _paintMan(canvas, cx, cy, size.width);
      case KidPicture.cat:
        _paintCat(canvas, cx, cy, size.width);
      case KidPicture.sun:
        _paintSun(canvas, cx, cy, size.width);
      case KidPicture.ball:
        _paintBall(canvas, cx, cy, size.width);
    }
  }

  void _paintBat(Canvas canvas, double cx, double cy, double w) {
    final body = Paint()..color = const Color(0xFF5D4037);
    final wing = Paint()..color = const Color(0xFF795548);
    final path = Path()
      ..moveTo(cx - w * 0.42, cy)
      ..quadraticBezierTo(cx - w * 0.28, cy - w * 0.28, cx - w * 0.08, cy - w * 0.06)
      ..lineTo(cx, cy - w * 0.02)
      ..lineTo(cx + w * 0.08, cy - w * 0.06)
      ..quadraticBezierTo(cx + w * 0.28, cy - w * 0.28, cx + w * 0.42, cy)
      ..quadraticBezierTo(cx + w * 0.22, cy + w * 0.08, cx + w * 0.06, cy + w * 0.04)
      ..lineTo(cx, cy + w * 0.06)
      ..lineTo(cx - w * 0.06, cy + w * 0.04)
      ..quadraticBezierTo(cx - w * 0.22, cy + w * 0.08, cx - w * 0.42, cy)
      ..close();
    canvas.drawPath(path, wing);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + w * 0.02), width: w * 0.22, height: w * 0.18),
      body,
    );
    canvas.drawCircle(Offset(cx - w * 0.04, cy - w * 0.01), w * 0.025, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + w * 0.04, cy - w * 0.01), w * 0.025, Paint()..color = Colors.white);
  }

  void _paintBag(Canvas canvas, double cx, double cy, double w) {
    final bag = Paint()..color = const Color(0xFFFF8A65);
    final strap = Paint()
      ..color = const Color(0xFFE64A19)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + w * 0.06), width: w * 0.55, height: w * 0.48),
        Radius.circular(w * 0.08),
      ),
      bag,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - w * 0.08), width: w * 0.42, height: w * 0.36),
      math.pi,
      math.pi,
      false,
      strap,
    );
    canvas.drawCircle(Offset(cx, cy + w * 0.08), w * 0.06, Paint()..color = const Color(0xFFFFD54F));
  }

  void _paintMat(Canvas canvas, double cx, double cy, double w) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w * 0.7, height: w * 0.42),
        Radius.circular(w * 0.06),
      ),
      Paint()..color = const Color(0xFF66BB6A),
    );
    final stripe = Paint()..color = const Color(0xFFA5D6A7);
    for (var i = 0; i < 4; i++) {
      final y = cy - w * 0.14 + i * w * 0.09;
      canvas.drawLine(
        Offset(cx - w * 0.28, y),
        Offset(cx + w * 0.28, y),
        stripe..strokeWidth = w * 0.035,
      );
    }
  }

  void _paintMap(Canvas canvas, double cx, double cy, double w) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w * 0.62, height: w * 0.48),
        Radius.circular(w * 0.04),
      ),
      Paint()..color = const Color(0xFFFFE082),
    );
    final line = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.2, cy + w * 0.1)
        ..quadraticBezierTo(cx - w * 0.05, cy - w * 0.12, cx + w * 0.18, cy + w * 0.02),
      line,
    );
    canvas.drawCircle(Offset(cx + w * 0.12, cy - w * 0.08), w * 0.05, Paint()..color = const Color(0xFFE53935));
  }

  void _paintMan(Canvas canvas, double cx, double cy, double w) {
    canvas.drawCircle(Offset(cx, cy - w * 0.18), w * 0.14, Paint()..color = const Color(0xFFFFCC80));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + w * 0.08), width: w * 0.32, height: w * 0.34),
        Radius.circular(w * 0.06),
      ),
      Paint()..color = const Color(0xFF42A5F5),
    );
    canvas.drawCircle(Offset(cx - w * 0.05, cy - w * 0.2), w * 0.025, Paint()..color = const Color(0xFF5D4037));
    canvas.drawCircle(Offset(cx + w * 0.05, cy - w * 0.2), w * 0.025, Paint()..color = const Color(0xFF5D4037));
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - w * 0.14), width: w * 0.12, height: w * 0.08),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFFE57373)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );
  }

  void _paintCat(Canvas canvas, double cx, double cy, double w) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + w * 0.06), width: w * 0.5, height: w * 0.38),
      Paint()..color = const Color(0xFFFFB74D),
    );
    canvas.drawCircle(Offset(cx, cy - w * 0.12), w * 0.16, Paint()..color = const Color(0xFFFFB74D));
    final ear = Path()
      ..moveTo(cx - w * 0.14, cy - w * 0.18)
      ..lineTo(cx - w * 0.22, cy - w * 0.34)
      ..lineTo(cx - w * 0.04, cy - w * 0.24)
      ..close();
    canvas.drawPath(ear, Paint()..color = const Color(0xFFFFA726));
    final ear2 = Path()
      ..moveTo(cx + w * 0.14, cy - w * 0.18)
      ..lineTo(cx + w * 0.22, cy - w * 0.34)
      ..lineTo(cx + w * 0.04, cy - w * 0.24)
      ..close();
    canvas.drawPath(ear2, Paint()..color = const Color(0xFFFFA726));
    canvas.drawCircle(Offset(cx - w * 0.05, cy - w * 0.14), w * 0.03, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + w * 0.05, cy - w * 0.14), w * 0.03, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy - w * 0.08), w * 0.025, Paint()..color = const Color(0xFFE91E63));
  }

  void _paintSun(Canvas canvas, double cx, double cy, double w) {
    final ray = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + math.cos(a) * w * 0.22, cy + math.sin(a) * w * 0.22),
        Offset(cx + math.cos(a) * w * 0.38, cy + math.sin(a) * w * 0.38),
        ray,
      );
    }
    canvas.drawCircle(Offset(cx, cy), w * 0.2, Paint()..color = const Color(0xFFFFCA28));
  }

  void _paintBall(Canvas canvas, double cx, double cy, double w) {
    canvas.drawCircle(Offset(cx, cy), w * 0.28, Paint()..color = const Color(0xFFEF5350));
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.56, height: w * 0.56),
      -0.4,
      math.pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06,
    );
  }

  @override
  bool shouldRepaint(covariant _KidPicturePainter oldDelegate) =>
      oldDelegate.picture != picture;
}

KidPicture? pictureForWord(String word) {
  switch (word.toLowerCase()) {
    case 'bat':
      return KidPicture.bat;
    case 'bag':
      return KidPicture.bag;
    case 'mat':
      return KidPicture.mat;
    case 'map':
      return KidPicture.map;
    case 'man':
      return KidPicture.man;
    case 'cat':
      return KidPicture.cat;
    case 'sun':
      return KidPicture.sun;
    case 'ball':
      return KidPicture.ball;
    default:
      return null;
  }
}
