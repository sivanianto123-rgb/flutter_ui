import 'package:flutter/material.dart';

class RockWidget extends StatelessWidget {
  final double width;
  final double height;

  const RockWidget({super.key, this.width = 48, this.height = 30});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _RockPainter(),
    );
  }
}

class _RockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = const Color(0xFFBF6B0A);
    final highlight = Paint()..color = const Color(0xFFD4860A);

    final path = Path()
      ..moveTo(size.width * 0.15, size.height)
      ..quadraticBezierTo(0, size.height * 0.6, size.width * 0.08, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.3, 0, size.width * 0.55, size.height * 0.05)
      ..quadraticBezierTo(size.width * 0.85, 0, size.width * 0.95, size.height * 0.35)
      ..quadraticBezierTo(size.width, size.height * 0.65, size.width * 0.85, size.height)
      ..close();

    canvas.drawPath(path, base);

    // Highlight on top-left edge
    final hlPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.05, size.height * 0.4, size.width * 0.2, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.02, size.width * 0.6, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.08, size.width * 0.18, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.08, size.height * 0.5, size.width * 0.2, size.height * 0.7)
      ..close();

    canvas.drawPath(hlPath, highlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
