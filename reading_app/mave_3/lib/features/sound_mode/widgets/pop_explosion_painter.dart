import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A celebratory explosion animation shown when a bubble is correctly tapped.
class PopExplosion extends StatefulWidget {
  const PopExplosion({
    super.key,
    required this.size,
    required this.onComplete,
  });

  final double       size;
  final VoidCallback onComplete;

  @override
  State<PopExplosion> createState() => _PopExplosionState();
}

class _PopExplosionState extends State<PopExplosion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  static const _colors = [
    Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4),
    Color(0xFF6BCB77), Color(0xFFA855F7), Color(0xFFFF9F43),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) {
        return SizedBox(
          width:  widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ExplosionPainter(progress: _anim.value, colors: _colors),
          ),
        );
      },
    );
  }
}

class _ExplosionPainter extends CustomPainter {
  const _ExplosionPainter({required this.progress, required this.colors});
  final double       progress;
  final List<Color>  colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR   = size.width * 0.48;
    final count  = 12;

    for (int i = 0; i < count; i++) {
      final angle  = i * 2 * math.pi / count;
      final r      = maxR * progress;
      final x      = center.dx + r * math.cos(angle);
      final y      = center.dy + r * math.sin(angle);
      final alpha  = (1.0 - progress).clamp(0.0, 1.0);
      final color  = colors[i % colors.length].withOpacity(alpha);
      final radius = (size.width * 0.08) * (1.0 - progress * 0.5);

      canvas.drawCircle(Offset(x, y), radius, Paint()..color = color);
    }

    // Central flash
    if (progress < 0.3) {
      final alpha = (1.0 - progress / 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(center, maxR * progress * 0.6,
          Paint()..color = Colors.white.withOpacity(alpha * 0.7));
    }
  }

  @override
  bool shouldRepaint(_ExplosionPainter old) => old.progress != progress;
}
