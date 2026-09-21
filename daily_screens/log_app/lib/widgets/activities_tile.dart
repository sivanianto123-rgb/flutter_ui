import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:log_app/styles/colors/colors.dart';
import 'package:log_app/styles/fonts/fonts.dart';
import 'package:bulleted_list/bulleted_list.dart';

class ActivitiesTile extends StatelessWidget {
  const ActivitiesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 163,
          height: 267,
          decoration: BoxDecoration(
            color: AppColors.pink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Today Meets', style: AppFonts.w600b16),
                SizedBox(height: 45),
                // BulletedList(
                //   bulletColor: AppColors.primarycolor,

                //   listItems: [
                //     '16:00 \n Drogomanovo St',
                //     '17:00 \n Drogomanovo St',
                //   ],
                // ),
                Row(
                  children: [
                    DotsIndicator(
                      dotsCount: 1,
                      decorator: DotsDecorator(
                        activeColor: AppColors.primarycolor,
                        size: Size(3, 3),
                      ),
                    ),
                    SizedBox(width: 3),
                    Text('16:00 \n Drogomanovo St', style: AppFonts.w500b10),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    DotsIndicator(
                      dotsCount: 1,
                      decorator: DotsDecorator(
                        activeColor: AppColors.primarycolor,
                        size: Size(3, 3),
                      ),
                    ),
                    SizedBox(width: 3),
                    Text('16:00 \n Drogomanovo St', style: AppFonts.w500b10),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    DotsIndicator(
                      dotsCount: 1,
                      decorator: DotsDecorator(
                        activeColor: AppColors.primarycolor,
                        size: Size(3, 3),
                      ),
                    ),
                    SizedBox(width: 3),
                    Text('16:00 \n Drogomanovo St', style: AppFonts.w500b10),
                  ],
                ),
                SizedBox(height: 35),

                Row(
                  children: [
                    Text('See all meets', style: AppFonts.w500b10),
                    SizedBox(width: 37),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        Column(
          children: [
            Container(
              width: 210,
              height: 122,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blue,
              ),
              child: Column(
                children: [
                  Text('Planned call', style: AppFonts.w600b16),
                  SizedBox(height: 12),
                  Text('Support toom coll', style: AppFonts.w500b10),
                  SizedBox(height: 15),
                  Text('17:00', style: AppFonts.w500b12),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 210,
              height: 122,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blue,
              ),
              child: Column(
                children: [
                  Text('Leads activity', style: AppFonts.w600b16),
                  SizedBox(height: 10),
                  Text(
                    'For lost 4 days on \n Pechorsky Project',
                    style: AppFonts.w500b10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
