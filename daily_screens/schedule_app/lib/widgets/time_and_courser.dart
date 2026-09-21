import 'package:flutter/material.dart';
import 'package:schedule_app/styles/colors/colors.dart';
import 'package:schedule_app/styles/fonts/fonts.dart';

class TimesAndCourses extends StatelessWidget {
  const TimesAndCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'Time',
                style: AppFonts.getAppFont(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.hinttext,
                ),
              ),
              SizedBox(width: 40),
              Text(
                'Course',
                style: AppFonts.getAppFont(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.hinttext,
                ),
              ),
              Spacer(),
              Icon(Icons.sort, color: AppColors.hinttext),
            ],
          ),
        ),
        SizedBox(height: 16),
        _courseItem(
          startTime: '11:35',
          endTime: '13:05',
          subject: 'Mathematics',
          chapter: 'Chapter 1: Introduction',
          room: 'Room 6-205',
          teacher: 'Brooklyn Williamson',
          isHighlighted: true,
        ),
        SizedBox(height: 16),
        _courseItem(
          startTime: '13:15',
          endTime: '14:45',
          subject: 'Biology',
          chapter: 'Chapter 3: Animal Kingdom',
          room: 'Room 2-168',
          teacher: 'Julie Watson',
          isHighlighted: false,
        ),
        SizedBox(height: 16),
        _courseItem(
          startTime: '15:10',
          endTime: '16:40',
          subject: 'Geography',
          chapter: 'Chapter 2: Economy USA',
          room: 'Room 1-403',
          teacher: 'Jenny Alexander',
          isHighlighted: false,
        ),
      ],
    );
  }

  Widget _courseItem({
    required String startTime,
    required String endTime,
    required String subject,
    required String chapter,
    required String room,
    required String teacher,
    required bool isHighlighted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: AppFonts.getAppFont(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textcolor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  endTime,
                  style: AppFonts.getAppFont(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.hinttext,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppColors.secondarycolor
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subject,
                        style: AppFonts.getAppFont(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: isHighlighted
                              ? AppColors.primarycolor
                              : AppColors.textcolor,
                        ),
                      ),
                      Icon(
                        Icons.more_vert,
                        color: isHighlighted
                            ? AppColors.primarycolor
                            : AppColors.hinttext,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    chapter,
                    style: AppFonts.getAppFont(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: isHighlighted
                          ? AppColors.primarycolor
                          : AppColors.textcolor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: isHighlighted
                            ? AppColors.primarycolor.withOpacity(0.8)
                            : AppColors.hinttext,
                      ),
                      SizedBox(width: 8),
                      Text(
                        room,
                        style: AppFonts.getAppFont(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: isHighlighted
                              ? AppColors.primarycolor
                              : AppColors.textcolor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: const AssetImage(
                          'lib/assets/images/p.png',
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        teacher,
                        style: AppFonts.getAppFont(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: isHighlighted
                              ? AppColors.primarycolor
                              : AppColors.textcolor,
                        ),
                      ),
                    ],
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
