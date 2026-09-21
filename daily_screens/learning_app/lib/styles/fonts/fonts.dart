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

  static final TextStyle w700primaryText32 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: AppColors.primarytext,
  );
  static final TextStyle w400primaryText16 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.primarytext,
  );
  static final TextStyle w700hintText15 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: Color(0xFFBABABA),
  );
  static final TextStyle w700primaryText24 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: Colors.white,
  );
  static final TextStyle w700primaryText15 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: Colors.white,
  );
  static final TextStyle w700primaryText18 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: Colors.white,
  );
}
