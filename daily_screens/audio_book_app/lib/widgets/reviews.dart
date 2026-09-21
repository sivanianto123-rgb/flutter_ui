import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../styles/fonts.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: AppFonts.w600b17),
              Text('View All', style: AppFonts.w400g13),
            ],
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: AppColors.grey, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ronald Richards', style: AppFonts.w500b13),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppColors.grey,
                            ),
                            SizedBox(width: 4),
                            Text('13 Sep, 2020', style: AppFonts.w400g11),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text('4.8', style: AppFonts.w500b13),
                          SizedBox(width: 4),
                          Text('rating', style: AppFonts.w400g11),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.starYellow,
                          ),
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.starYellow,
                          ),
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.starYellow,
                          ),
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.starYellow,
                          ),
                          Icon(
                            Icons.star_border,
                            size: 14,
                            color: AppColors.starYellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque malesuada eget vitae amet...',
                style: AppFonts.w400g15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
