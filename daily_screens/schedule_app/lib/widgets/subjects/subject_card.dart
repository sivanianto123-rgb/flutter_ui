import 'package:flutter/material.dart';
import 'package:schedule_app/styles/fonts/fonts.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color baseColor;
  final Color blobColor;

  const SubjectCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.baseColor,
    required this.blobColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 180,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: blobColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(60),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      iconPath,
                      width: 32,
                      height: 32,
                      color: Colors.white,
                    ),
                    const Icon(Icons.more_vert, color: Colors.white),
                  ],
                ),
                const Spacer(),
                Text(title, style: AppFonts.w600w16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
