import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule_app/styles/colors/colors.dart';

class AppFonts {
  static TextStyle getAppFont({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static final w800b24 = getAppFont(
    fontWeight: FontWeight.w800,
    fontSize: 24,
    color: AppColors.textcolor,
  );
  static final w400g14 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.hinttext,
  );
  static final w500b24 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 24,
    color: AppColors.textcolor,
  );
  static final w600w16 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.primarycolor,
  );
  static final w400w12 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.primarycolor,
  );
}
