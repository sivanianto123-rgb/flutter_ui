import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final borderPaint = Paint()
      ..color = const Color(0xFFB5660A)
      ..strokeWidth = 130
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mainPaint = Paint()
      ..color = const Color(0xFFE8931A)
      ..strokeWidth = 112
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final innerPaint = Paint()
      ..color = const Color(0xFFF5AB30)
      ..strokeWidth = 72
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerPaint = Paint()
      ..color = const Color(0xFFFABC40)
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(w * 0.0, h * 0.88)
      ..cubicTo(w * 0.08, h * 0.82, w * 0.10, h * 0.75, w * 0.16, h * 0.72)
      ..cubicTo(w * 0.22, h * 0.68, w * 0.20, h * 0.82, w * 0.26, h * 0.85)
      ..cubicTo(w * 0.30, h * 0.88, w * 0.34, h * 0.82, w * 0.38, h * 0.76)
      ..cubicTo(w * 0.42, h * 0.70, w * 0.44, h * 0.56, w * 0.46, h * 0.50)
      ..cubicTo(w * 0.50, h * 0.42, w * 0.52, h * 0.30, w * 0.54, h * 0.28)
      ..cubicTo(w * 0.58, h * 0.25, w * 0.66, h * 0.32, w * 0.68, h * 0.42)
      ..cubicTo(w * 0.70, h * 0.50, w * 0.68, h * 0.58, w * 0.72, h * 0.62)
      ..cubicTo(w * 0.76, h * 0.66, w * 0.82, h * 0.72, w * 0.84, h * 0.70)
      ..cubicTo(w * 0.88, h * 0.68, w * 0.96, h * 0.72, w * 1.0, h * 0.70);

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, mainPaint);
    canvas.drawPath(path, innerPaint);
    canvas.drawPath(path, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
