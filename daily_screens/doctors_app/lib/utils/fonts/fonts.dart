import 'package:docters_app/utils/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextStyle getAppFont({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.leagueSpartan(
      textStyle: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static final w400b12 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.secondarycolor,
  );
  static final w500b14 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.secondarycolor,
  );
  static final w500b24 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    color: AppColors.secondarycolor,
  );
  static final w400bl10 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 10,
    color: AppColors.primarytextcolor,
  );
  static final w400bl12 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.primarytextcolor,
  );
  static final w500bl13 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.primarytextcolor,
  );
  static final w500bl14 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.primarytextcolor,
  );
  static final w400w12 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.secondarytextcolor,
  );
  static final w500w12 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.secondarytextcolor,
  );
  static final w500w24 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    color: AppColors.secondarytextcolor,
  );
}
