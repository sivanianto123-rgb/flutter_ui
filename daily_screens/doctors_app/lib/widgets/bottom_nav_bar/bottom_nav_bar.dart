import 'package:docters_app/utils/colors/colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.secondarycolor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => onTap(0),
              child: Icon(
                currentIndex == 0 ? Icons.home : Icons.home_outlined,
                size: 28,
                color: currentIndex == 0
                    ? AppColors.primarycolor
                    : Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () => onTap(1),
              child: Icon(
                currentIndex == 1
                    ? Icons.chat_bubble
                    : Icons.chat_bubble_outline,
                size: 28,
                color: currentIndex == 1
                    ? AppColors.primarycolor
                    : Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () => onTap(2),
              child: Icon(
                currentIndex == 2 ? Icons.person : Icons.person_outline,
                size: 28,
                color: currentIndex == 2
                    ? AppColors.primarycolor
                    : Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () => onTap(3),
              child: Icon(
                currentIndex == 3
                    ? Icons.calendar_today
                    : Icons.calendar_today_outlined,
                size: 28,
                color: currentIndex == 3
                    ? AppColors.primarycolor
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
