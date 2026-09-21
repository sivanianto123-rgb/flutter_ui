import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  ConfettiOverlay({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ConfettiPiece> _pieces = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generatePieces();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  void _generatePieces() {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];

    for (int i = 0; i < 80; i++) {
      _pieces.add(
        ConfettiPiece(
          x: _random.nextDouble(),
          delay: _random.nextDouble() * 0.4,
          speed: 0.4 + _random.nextDouble() * 0.6,
          color: colors[_random.nextInt(colors.length)],
          size: 6 + _random.nextDouble() * 10,
          rotation: _random.nextDouble() * 360,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class ConfettiPiece {
  final double x;
  final double delay;
  final double speed;
  final Color color;
  final double size;
  final double rotation;

  ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.color,
    required this.size,
    required this.rotation,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;

  ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      double adjusted = ((progress - piece.delay) / piece.speed).clamp(
        0.0,
        1.0,
      );
      if (adjusted <= 0) continue;

      double y = adjusted * size.height * 1.3;
      double x = piece.x * size.width + sin(adjusted * 8 + piece.rotation) * 40;
      double opacity = (1 - adjusted).clamp(0.0, 1.0);

      Paint paint = Paint()
        ..color = piece.color.withAlpha((255 * opacity).toInt())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(adjusted * piece.rotation * 0.1);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 1.5,
          ),
          Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
