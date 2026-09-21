import 'package:flutter/material.dart';

import '../../utils/colors/colors.dart';
import '../../utils/fonts/fonts.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('lib/assets/images/p1.png'),
                ),
              ),
              SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi, WelcomeBack', style: AppFonts.w400b12),
                  Column(
                    children: [Text('John Doe', style: AppFonts.w500bl14)],
                  ),
                ],
              ),
              SizedBox(width: 130),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarycolor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.circle_notifications_outlined, size: 20),
              ),
              SizedBox(width: 5),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarycolor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.settings, size: 20),
              ),
            ],
          ),
          SizedBox(height: 22),
          Row(
            children: [
              Column(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    color: AppColors.secondarycolor,
                    size: 30,
                  ),
                  SizedBox(height: 2),
                  Text('Doctors', style: AppFonts.w400b12),
                ],
              ),
              SizedBox(width: 38),
              Column(
                children: [
                  Icon(
                    Icons.favorite_border_outlined,
                    color: AppColors.secondarycolor,
                    size: 30,
                  ),
                  SizedBox(height: 2),
                  Text('Favorite', style: AppFonts.w400b12),
                ],
              ),
              SizedBox(width: 29),
              Container(
                width: 210,
                height: 33,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  color: AppColors.primarycolor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.secondarytextcolor,
                        ),
                        child: Icon(Icons.filter_2, size: 10),
                      ),
                      Icon(Icons.search_outlined, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
