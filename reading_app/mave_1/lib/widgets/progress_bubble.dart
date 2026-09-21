import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/providers/app_providers.dart';

class ProgressBubble extends ConsumerWidget {
  final double size;
  const ProgressBubble({super.key, this.size = 100});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, _) => CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(progress: value),
            ),
          ),
          // Percentage text
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress * 100),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${value.round()}%',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'done',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: size * 0.13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.progressBg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Progress arc
    final arcPaint = Paint()
      ..color = AppColors.progressRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
