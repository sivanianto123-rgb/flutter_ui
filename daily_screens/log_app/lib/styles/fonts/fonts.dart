import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:log_app/styles/colors/colors.dart';

class AppFonts {
  static TextStyle getAppFont({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.manrope(
      textStyle: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static final w500w10 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: AppColors.secondarycol0r,
  );
  static final w600w14 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.secondarycol0r,
  );
  static final w600w16 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.secondarycol0r,
  );
  static final w600w18 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.secondarycol0r,
  );
  static final w600b16 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.primarycolor,
  );
  static final w500b14 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.primarycolor,
  );
  static final w500b12 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.primarycolor,
  );
  static final w500b10 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: AppColors.primarycolor,
  );
}
