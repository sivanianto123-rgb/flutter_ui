import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_settings_provider.dart';

class PhonicsForestBackground extends ConsumerWidget {
  const PhonicsForestBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appSettingsProvider).isDarkMode;
    return Positioned.fill(
      child: CustomPaint(painter: _ForestThemeBackdropPainter(isDarkMode)),
    );
  }
}

class _ForestThemeBackdropPainter extends CustomPainter {
  const _ForestThemeBackdropPainter(this.isDarkMode);
  final bool isDarkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? const [Color(0xFF0A1932), Color(0xFF1B3A57), Color(0xFF2E4E69)]
              : const [Color(0xFF1565C0), Color(0xFF4FC3F7), Color(0xFFB3E5FC)],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(Offset.zero & size),
    );

    canvas.drawCircle(
      Offset(w * 0.16, h * 0.12),
      46,
      Paint()..color = isDarkMode ? const Color(0x55E3F2FD) : const Color(0x66FFD740),
    );

    final cloudPaint = Paint()
      ..color = isDarkMode ? const Color(0x88CFD8DC) : const Color(0xEEFFFFFF);
    _cloud(canvas, cloudPaint, Offset(w * 0.60, h * 0.11), 48);
    _cloud(canvas, cloudPaint, Offset(w * 0.82, h * 0.21), 34);

    final hillPath = Path()
      ..moveTo(0, h * 0.64)
      ..quadraticBezierTo(w * 0.26, h * 0.52, w * 0.54, h * 0.64)
      ..quadraticBezierTo(w * 0.74, h * 0.72, w, h * 0.60)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hillPath,
      Paint()..color = isDarkMode ? const Color(0xAA1B3A31) : const Color(0xAA2E7D32),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.70, w, h * 0.30),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? const [Color(0xFF2C5A39), Color(0xFF13281A)]
              : const [Color(0xFF43A047), Color(0xFF1B5E20)],
        ).createShader(Rect.fromLTWH(0, h * 0.7, w, h * 0.3)),
    );
  }

  void _cloud(Canvas canvas, Paint paint, Offset center, double r) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center + Offset(r * 0.72, 0), r * 0.78, paint);
    canvas.drawCircle(center - Offset(r * 0.72, 0), r * 0.72, paint);
    canvas.drawCircle(center + Offset(r * 0.25, -r * 0.42), r * 0.62, paint);
  }

  @override
  bool shouldRepaint(covariant _ForestThemeBackdropPainter oldDelegate) =>
      oldDelegate.isDarkMode != isDarkMode;
}
