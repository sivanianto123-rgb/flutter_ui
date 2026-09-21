import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

/// Large, pulsing "Next" button designed for toddler-sized fingers (≥ 80×80 dp).
///
/// - Pulses infinitely via [flutter_animate] to draw attention.
/// - Debounces taps with a 1-second cooldown so rapid multi-taps from excited
///   toddlers don't skip several levels at once.
/// - Set [isFinish] to swap the arrow icon for a home icon on Level 4.
class MaveNextButton extends StatefulWidget {
  const MaveNextButton({
    super.key,
    required this.onTap,
    this.isFinish = false,
  });

  final VoidCallback onTap;

  /// When true the icon shows Icons.home_rounded instead of an arrow.
  final bool isFinish;

  @override
  State<MaveNextButton> createState() => _MaveNextButtonState();
}

class _MaveNextButtonState extends State<MaveNextButton> {
  bool _cooling = false;

  void _handleTap() {
    if (_cooling) return;
    setState(() => _cooling = true);
    widget.onTap();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _cooling = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isFinish ? AppColors.accentGreen : AppColors.accent;
    final icon = widget.isFinish
        ? Icons.home_rounded
        : Icons.arrow_forward_rounded;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: _cooling ? color.withAlpha(160) : color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 48, color: Colors.white),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.04, 1.04),
          duration: 700.ms,
          curve: Curves.easeInOut,
        )
        .animate() // entrance animation (runs once)
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.4, 0.4),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.elasticOut,
        );
  }
}
