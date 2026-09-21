import 'package:flutter/material.dart';
import 'package:log_app/styles/colors/colors.dart';
import 'package:log_app/styles/fonts/fonts.dart';
import 'package:log_app/widgets/campaingntile.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.secondarycol0r),
                      SizedBox(width: 15),
                      Text('Profile', style: AppFonts.w600w18),
                    ],
                  ),
                  Icon(Icons.tune, color: AppColors.secondarycol0r),
                ],
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage('lib/assets/images/profile.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('DuozhuaMiao', style: AppFonts.w600w18),
                          SizedBox(width: 8),
                          Icon(
                            Icons.edit,
                            color: AppColors.secondarycol0r,
                            size: 18,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text('123 456 7899', style: AppFonts.w500w10),
                      SizedBox(height: 3),
                      Text('Username@email.com', style: AppFonts.w500w10),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text('Projects', style: AppFonts.w600w18),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFF1CE15E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project\nGreenville Park',
                            style: AppFonts.w500b14,
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(
                                  'lib/assets/images/project1.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(
                                Icons.single_bed,
                                color: AppColors.primarycolor,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '15 Avalobte flots',
                                style: AppFonts.w500b10,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                color: AppColors.primarycolor,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text('21 Views', style: AppFonts.w500b10),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.primarycolor,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text('234 Cueks', style: AppFonts.w500b10),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text('4 Chats', style: AppFonts.w500b10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Comfort\ntown',
                            style: AppFonts.w500b14,
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(
                                  'lib/assets/images/project2.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(
                                Icons.single_bed,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '15 Avalobte flots',
                                style: AppFonts.w500b10,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text('21 Views', style: AppFonts.w500b10),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text('234 Cueks', style: AppFonts.w500b10),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text('4 Chats', style: AppFonts.w500b10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Campaign', style: AppFonts.w600b16),
                        Image(image: AssetImage('lib/assets/images/star.png')),
                      ],
                    ),
                    Text('Cottage town Inwood', style: AppFonts.w500b10),
                    SizedBox(height: 15),
                    Campaingntile(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Color(0xFF6B6A69),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Archive campaign(3)', style: AppFonts.w600w16),
                    Icon(Icons.arrow_forward, color: AppColors.secondarycol0r),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
