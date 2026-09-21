import 'package:flutter/material.dart';

class CartoonProgressBar extends StatelessWidget {
  const CartoonProgressBar({
    super.key,
    required this.value,
    this.height = 34,
    this.showPercent = true,
    this.checkpointCount = 0,
    this.currentCheckpoint = 0,
    this.onCheckpointTap,
  });

  final double value;
  final double height;
  final bool showPercent;
  final int checkpointCount;
  final int currentCheckpoint;
  final ValueChanged<int>? onCheckpointTap;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final percent = (v * 100).round();

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFC8CFF6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF8D9BE9), width: 1.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(color: const Color(0xFFAAB4EA)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF67E6), Color(0xFFD94DF0)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                              painter: _StripePainter(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (checkpointCount > 1)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(checkpointCount, (i) {
                            final reached = i <= currentCheckpoint;
                            return GestureDetector(
                              onTap: onCheckpointTap == null ? null : () => onCheckpointTap!(i),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 22,
                                alignment: Alignment.center,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: reached
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.45),
                                    border: Border.all(
                                      color: const Color(0xAA7A86D9),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showPercent) ...[
            const SizedBox(width: 10),
            Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Color(0xAA5C69BA), blurRadius: 2)],
              ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()..color = Colors.white.withValues(alpha: 0.16);
    const stripeWidth = 16.0;
    const gap = 12.0;
    for (double x = -size.height; x < size.width + size.height; x += stripeWidth + gap) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) => false;
}
