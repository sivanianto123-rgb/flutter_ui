import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:score_app/styles/colors/colors.dart';

class Mulish {
  static TextStyle getAppFont({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.mulish(
      textStyle: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static final w700w24 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.primarytextcolor,
  );
  static final w500w12 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.primarytextcolor,
  );
  static final w500g12 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: Color(0xFF027A48),
  );
  static final w500gr12 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: Color(0xFFB6B6B6),
  );
}

class Inter {
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

  static final w500w12 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.primarytextcolor,
  );
  static final w600w20 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: AppColors.primarytextcolor,
  );
  static final w500g12 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.unactivetext,
  );
}
