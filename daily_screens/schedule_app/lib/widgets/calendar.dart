import 'package:flutter/material.dart';
import 'package:schedule_app/styles/colors/colors.dart';
import 'package:schedule_app/styles/fonts/fonts.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  int selectedIndex = 3;

  final List<Map<String, String>> days = [
    {'day': 'S', 'date': '19'},
    {'day': 'M', 'date': '20'},
    {'day': 'T', 'date': '21'},
    {'day': 'W', 'date': '22'},
    {'day': 'T', 'date': '23'},
    {'day': 'F', 'date': '24'},
    {'day': 'S', 'date': '25'},
    {'day': 'S', 'date': '26'},
    {'day': 'M', 'date': '27'},
    {'day': 'T', 'date': '28'},
    {'day': 'W', 'date': '29'},
    {'day': 'T', 'date': '30'},
    {'day': 'F', 'date': '31'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                days[selectedIndex]['date']!,
                style: AppFonts.getAppFont(
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  color: AppColors.textcolor,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFullDay(days[selectedIndex]['day']!),
                    style: AppFonts.getAppFont(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.hinttext,
                    ),
                  ),
                  Text(
                    'Jan 2020',
                    style: AppFonts.getAppFont(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.hinttext,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.hinttext.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Today',
                  style: AppFonts.getAppFont(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFFFF6B4A),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  width: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFFF6B4A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index]['day']!,
                        style: AppFonts.getAppFont(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: isSelected
                              ? AppColors.primarycolor
                              : AppColors.hinttext,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        days[index]['date']!,
                        style: AppFonts.getAppFont(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: isSelected
                              ? AppColors.primarycolor
                              : AppColors.textcolor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getFullDay(String shortDay) {
    switch (shortDay) {
      case 'S':
        return 'Sun';
      case 'M':
        return 'Mon';
      case 'T':
        return 'Tue';
      case 'W':
        return 'Wed';
      case 'F':
        return 'Fri';
      default:
        return shortDay;
    }
  }
}
