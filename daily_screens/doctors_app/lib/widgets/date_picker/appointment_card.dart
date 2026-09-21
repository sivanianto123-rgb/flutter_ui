import 'package:docters_app/utils/colors/colors.dart';
import 'package:docters_app/utils/fonts/fonts.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.secondarytextcolor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Text('9 AM', style: AppFonts.w400b12),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DottedLine(
                    dashColor: AppColors.secondarycolor,
                    dashLength: 5,
                    dashGapLength: 3,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 45,
                  child: Text('10 AM\n11 AM', style: AppFonts.w400b12),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: AppColors.primarycolor,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dr. Olivia Turner, M.D.',
                                style: AppFonts.w500b14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.check,
                              color: AppColors.secondarycolor,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.close,
                              color: AppColors.secondarycolor,
                              size: 14,
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Treatment and prevention',
                          style: AppFonts.w400bl10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Text('12 PM', style: AppFonts.w400b12),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DottedLine(
                    dashColor: AppColors.secondarycolor,
                    dashLength: 5,
                    dashGapLength: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
