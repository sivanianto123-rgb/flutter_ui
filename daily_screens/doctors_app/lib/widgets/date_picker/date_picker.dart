import 'package:docters_app/utils/colors/colors.dart';
import 'package:docters_app/utils/fonts/fonts.dart';
import 'package:docters_app/widgets/date_picker/appointment_card.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({super.key});

  final List<Map<String, String>> dates = const [
    {'day': '9', 'label': 'MON'},
    {'day': '10', 'label': 'TUE'},
    {'day': '11', 'label': 'WED'},
    {'day': '12', 'label': 'THU'},
    {'day': '13', 'label': 'FRI'},
    {'day': '14', 'label': 'SAT'},
    {'day': '15', 'label': 'SUN'},
    {'day': '16', 'label': 'MON'},
    {'day': '17', 'label': 'TUE'},
    {'day': '18', 'label': 'WED'},
    {'day': '19', 'label': 'THU'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primarycolor,
      child: Padding(
        padding: EdgeInsets.only(left: 30, right: 30, top: 16, bottom: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return Container(
                    width: 42,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.secondarytextcolor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dates[index]['day']!, style: AppFonts.w500b24),
                        Text(dates[index]['label']!, style: AppFonts.w400bl12),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 9),
            AppointmentCard(),
          ],
        ),
      ),
    );
  }
}
