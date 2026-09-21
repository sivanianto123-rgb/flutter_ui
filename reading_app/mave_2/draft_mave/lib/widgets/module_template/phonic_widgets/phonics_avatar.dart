import 'dart:math' as math;

import '../../../utils/common_import.dart';

class PhonicsAvatar extends StatefulWidget {
  final String phonicSound;
  final String characterImage;
  final VoidCallback? onTap;

  const PhonicsAvatar({
    super.key,
    required this.phonicSound,
    required this.characterImage,
    this.onTap,
  });

  @override
  State<PhonicsAvatar> createState() => _PhonicsAvatarState();
}

class _PhonicsAvatarState extends State<PhonicsAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: s * 0.45,
        height: s * 0.50,
        decoration: BoxDecoration(
          color: AppColors.moduleCircleStroke,
          borderRadius: BorderRadius.circular(s * 0.18),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 15),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: s * 0.38,
            height: s * 0.42,
            decoration: BoxDecoration(
              color: AppColors.moduleCircleFill,
              borderRadius: BorderRadius.circular(s * 0.14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImage(s),
                SizedBox(height: s * 0.015),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => _buildText(s),
                ),
                SizedBox(height: s * 0.012),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => _buildArrow(s),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(double s) {
    return Container(
      width: s * 0.16,
      height: s * 0.12,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(s * 0.03),
      ),
      padding: const EdgeInsets.all(6),
      child: Image.asset(widget.characterImage, fit: BoxFit.contain),
    );
  }

  Widget _buildText(double s) {
    final text = widget.phonicSound;
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFFE66D),
      const Color(0xFF4ECDC4),
      const Color(0xFFFF6B9D),
    ];

    final colorIndex =
        (_controller.value * colors.length * 2).floor() % colors.length;
    final color = colors[colorIndex];

    return Text(
      text,
      style: AppFonts.w700white106.copyWith(fontSize: s * 0.09, color: color),
    );
  }

  Widget _buildArrow(double s) {
    final progress = _controller.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final delay = i * 0.15;
        final t = ((progress * 2) - delay) % 1.0;
        final opacity =
            t > 0 && t < 0.5 ? (math.sin(t * math.pi * 2) + 1) / 2 : 0.3;

        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Padding(
            padding: EdgeInsets.only(right: s * 0.002),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.white,
              size: s * 0.035,
            ),
          ),
        );
      }),
    );
  }
}
