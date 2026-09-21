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

  static final TextStyle w500b21 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 21,
    color: AppColors.primaytextColor,
  );
}
