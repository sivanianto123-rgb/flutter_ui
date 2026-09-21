import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppFonts {
  static TextStyle getAppFont({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static final w600b28 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 28,
    color: AppColors.primaryColor,
  );

  static final w600b22 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: AppColors.primaryColor,
  );

  static final w500b17 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 17,
    color: AppColors.primaryColor,
  );

  static final w600b17 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 17,
    color: AppColors.primaryColor,
  );

  static final w400b15 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColors.primaryColor,
  );

  static final w400b13 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.primaryColor,
  );

  static final w500b13 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors.primaryColor,
  );

  static final w400b11 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.primaryColor,
  );

  static final w400g15 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColors.grey,
  );

  static final w400g13 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.grey,
  );

  static final w400g11 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.grey,
  );

  static final w500w17 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 17,
    color: Colors.white,
  );

  static final w600b13 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: AppColors.primaryColor,
  );
}
