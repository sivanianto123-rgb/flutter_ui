import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../styles/fonts.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onTap(0),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentIndex == 0 ? Icons.home : Icons.home_outlined,
                    color: currentIndex == 0
                        ? AppColors.purple
                        : AppColors.grey,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Home',
                    style: AppFonts.w400b11.copyWith(
                      color: currentIndex == 0
                          ? AppColors.purple
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onTap(1),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentIndex == 1 ? Icons.favorite : Icons.favorite_outline,
                    color: currentIndex == 1
                        ? AppColors.purple
                        : AppColors.grey,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Wishlist',
                    style: AppFonts.w400b11.copyWith(
                      color: currentIndex == 1
                          ? AppColors.purple
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onTap(2),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentIndex == 2
                        ? Icons.shopping_bag
                        : Icons.shopping_bag_outlined,
                    color: currentIndex == 2
                        ? AppColors.purple
                        : AppColors.grey,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cart',
                    style: AppFonts.w400b11.copyWith(
                      color: currentIndex == 2
                          ? AppColors.purple
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onTap(3),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentIndex == 3 ? Icons.wallet : Icons.wallet_outlined,
                    color: currentIndex == 3
                        ? AppColors.purple
                        : AppColors.grey,
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Wallet',
                    style: AppFonts.w400b11.copyWith(
                      color: currentIndex == 3
                          ? AppColors.purple
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
