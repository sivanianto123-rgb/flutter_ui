import 'package:flutter/material.dart';
import 'package:linear_progress_bar/ui/dots_indicator.dart';
import 'package:linear_progress_bar/utils/dots_decorator.dart';

import '../styles/colors/colors.dart';

class Campaingntile extends StatelessWidget {
  Campaingntile({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.secondarycol0r,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DotsIndicator(
                dotsCount: 1,
                decorator: DotsDecorator(
                  size: Size(5, 5),
                  activeColor: AppColors.primarycolor,
                ),
              ),
              DotsIndicator(
                dotsCount: 1,
                decorator: DotsDecorator(
                  size: Size(5, 5),
                  activeColor: AppColors.primarycolor,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          child: Container(
            width: 170,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primarycolor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DotsIndicator(
                  dotsCount: 1,
                  decorator: DotsDecorator(
                    size: Size(5, 5),
                    activeColor: AppColors.secondarycol0r,
                  ),
                ),
                DotsIndicator(
                  dotsCount: 1,
                  decorator: DotsDecorator(
                    size: Size(5, 5),
                    activeColor: AppColors.secondarycol0r,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
