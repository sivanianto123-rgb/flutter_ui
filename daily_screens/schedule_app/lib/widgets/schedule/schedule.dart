import 'package:flutter/material.dart';
import 'package:schedule_app/styles/fonts/fonts.dart';
import 'package:schedule_app/widgets/schedule/schedule_card.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Schedule', style: AppFonts.w800b24),
          SizedBox(height: 2),
          Text('Next lessons', style: AppFonts.w400g14),
          SizedBox(height: 16),
          ScheduleCard(),
        ],
      ),
    );
  }
}
