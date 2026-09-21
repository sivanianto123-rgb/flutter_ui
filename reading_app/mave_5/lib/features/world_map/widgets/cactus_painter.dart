import 'dart:math' as math;
import 'package:flutter/material.dart';

class CactusPainter extends CustomPainter {
  final bool hasFlower;

  const CactusPainter({this.hasFlower = false});

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFF388E3C);
    final w = size.width;
    final h = size.height;

    // Main trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 6, h * 0.20, 12, h * 0.75), const Radius.circular(6)),
      body,
    );

    // Left arm (horizontal then up)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 22, h * 0.42, 16, 8), const Radius.circular(4)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 26, h * 0.26, 8, h * 0.18), const Radius.circular(4)),
      body,
    );

    // Right arm (horizontal then up)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 + 6, h * 0.54, 16, 8), const Radius.circular(4)),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 + 12, h * 0.38, 8, h * 0.18), const Radius.circular(4)),
      body,
    );

    if (hasFlower) {
      final cx = w / 2;
      final cy = h * 0.16;
      final petalPaint = Paint()..color = const Color(0xFFC62828);
      final centerPaint = Paint()..color = const Color(0xFFFFD700);
      for (int i = 0; i < 5; i++) {
        final angle = i * 2 * math.pi / 5;
        canvas.drawCircle(Offset(cx + 7 * math.cos(angle), cy + 7 * math.sin(angle)), 5, petalPaint);
      }
      canvas.drawCircle(Offset(cx, cy), 4, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
