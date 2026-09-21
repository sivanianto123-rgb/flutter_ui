import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// CustomPainter for the "pop" explosion effect on Level 3 taps.
class PopExplosionPainter extends CustomPainter {
  PopExplosionPainter({required this.progress});

  final double progress; // 0.0 → 1.0

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.5;
    final paint = Paint()..style = PaintingStyle.fill;

    // Outer burst ring
    paint.color = AppColors.accent.withAlpha((180 * (1 - progress)).round());
    canvas.drawCircle(center, maxRadius * progress, paint);

    // Particle sparks
    const int particles = 10;
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    for (int i = 0; i < particles; i++) {
      final angle = (i / particles) * 2 * pi;
      final dist = maxRadius * 1.2 * progress;
      final px = center.dx + cos(angle) * dist;
      final py = center.dy + sin(angle) * dist;
      final alpha = (220 * (1 - progress)).round();
      sparkPaint.color = AppColors.bubbleColors[i % AppColors.bubbleColors.length]
          .withAlpha(alpha.clamp(0, 255));
      final radius = 8 * (1 - progress);
      canvas.drawCircle(Offset(px, py), radius.clamp(1, 20), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(PopExplosionPainter old) => old.progress != progress;
}

/// A widget that shows a pop explosion animation.
class PopExplosion extends StatefulWidget {
  const PopExplosion({
    super.key,
    required this.onComplete,
    this.size = 120,
  });

  final VoidCallback onComplete;
  final double size;

  @override
  State<PopExplosion> createState() => _PopExplosionState();
}

class _PopExplosionState extends State<PopExplosion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => CustomPaint(
          painter: PopExplosionPainter(progress: _anim.value),
        ),
      ),
    );
  }
}
