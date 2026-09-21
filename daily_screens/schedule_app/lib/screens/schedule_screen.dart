import 'package:flutter/material.dart';

import '../styles/colors/colors.dart';
import '../widgets/calendar.dart';
import '../widgets/time_and_courser.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarycolor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 24),
              Calendar(),
              SizedBox(height: 24),
              Divider(color: Color(0xFFEEEEEE), thickness: 1),
              SizedBox(height: 16),
              TimesAndCourses(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
