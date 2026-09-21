import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors/colors.dart';

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

  static final TextStyle w500b16 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.primarytextcolor,
  );
  static final TextStyle w500b20 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 20,
    color: AppColors.primarytextcolor,
  );
  static final TextStyle w500b13 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors.primarytextcolor,
  );
  static final TextStyle w500b11 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: AppColors.primarytextcolor,
  );

  static final TextStyle w500r14 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.secondarytextcolor,
  );
  static final TextStyle w500r11 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: AppColors.primarytextcolor,
  );
  static final TextStyle w500r16 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.secondarytextcolor,
  );
  static final TextStyle w600r19 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 19,
    color: AppColors.secondarytextcolor,
  );
  static final TextStyle w500w11 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: Colors.white,
  );
  static final TextStyle w600w15 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: Colors.white,
  );
}
