import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Soft floating bubble background using CustomPainter.
class BubbleBackgroundPainter extends CustomPainter {
  BubbleBackgroundPainter({this.animationValue = 0.0});

  final double animationValue;

  static final List<_Bubble> _bubbles = _generateBubbles();

  static List<_Bubble> _generateBubbles() {
    final rng = Random(42); // fixed seed for determinism
    return List.generate(12, (i) {
      final color = AppColors.bubbleColors[i % AppColors.bubbleColors.length];
      return _Bubble(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 24 + rng.nextDouble() * 36,
        color: color,
        speed: 0.2 + rng.nextDouble() * 0.6,
        phase: rng.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final b in _bubbles) {
      final dy = sin(animationValue * b.speed * 2 * pi + b.phase) * 20;
      final cx = b.x * size.width;
      final cy = (b.y * size.height) + dy;

      paint.color = b.color.withAlpha(50);
      canvas.drawCircle(Offset(cx, cy), b.radius, paint);

      // Highlight
      paint.color = Colors.white.withAlpha(60);
      canvas.drawCircle(
        Offset(cx - b.radius * 0.3, cy - b.radius * 0.3),
        b.radius * 0.25,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BubbleBackgroundPainter old) =>
      old.animationValue != animationValue;
}

class _Bubble {
  const _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speed,
    required this.phase,
  });

  final double x;
  final double y;
  final double radius;
  final Color color;
  final double speed;
  final double phase;
}

/// An animated version that floats bubbles.
class AnimatedBubbleBackground extends StatefulWidget {
  const AnimatedBubbleBackground({super.key, this.child});
  final Widget? child;

  @override
  State<AnimatedBubbleBackground> createState() => _AnimatedBubbleBackgroundState();
}

class _AnimatedBubbleBackgroundState extends State<AnimatedBubbleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
          painter: BubbleBackgroundPainter(animationValue: _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
