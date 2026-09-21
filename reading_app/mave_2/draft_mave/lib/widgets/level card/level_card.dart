import 'dart:math' as math;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../utils/common_import.dart';

class LevelCard extends StatefulWidget {
  final String label;
  final String imagePath;
  final bool isUnlocked;
  final bool isFirst;
  final double progress;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.label,
    required this.imagePath,
    this.isUnlocked = false,
    this.isFirst = false,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isFirst && widget.isUnlocked) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final cardSize = shortestSide * 0.12;
    final starSize = shortestSide * 0.07;

    return GestureDetector(
      onTap: widget.isUnlocked ? widget.onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: widget.progress,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 1,
            ignoreGestures: true,
            itemSize: starSize,
            itemBuilder:
                (context, _) => Icon(
                  Icons.star_rounded,
                  color: GradientColors.starGradient[0],
                ),
            unratedColor: AppColors.white,
            onRatingUpdate: (_) {},
          ),
          SizedBoxesVertical.sizedBox8,
          _buildCard(cardSize),
          SizedBoxesVertical.sizedBox8,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: shortestSide * 0.02,
              vertical: shortestSide * 0.008,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.label,
              style: AppFonts.w500primaryText16.copyWith(
                fontSize: shortestSide * 0.018,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(double cardSize) {
    final card = Container(
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        color: widget.isFirst ? AppColors.secondaryAppColor : AppColors.white,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardSize / 2),
        child: Opacity(
          opacity: widget.isUnlocked ? 1.0 : 0.5,
          child: Image.asset(widget.imagePath, fit: BoxFit.cover),
        ),
      ),
    );

    if (_controller == null) return card;

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        final scale = 1.0 + 0.08 * math.sin(_controller!.value * math.pi * 2);
        final glowOpacity =
            0.3 + 0.3 * math.sin(_controller!.value * math.pi * 2);

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.moduleCircleStroke.withValues(
                  alpha: glowOpacity,
                ),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: card,
    );
  }
}
