import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/colors.dart';

class AppFonts {
  static TextStyle homeScreenText() {
    return GoogleFonts.chewy(fontSize: 59, color: AppColors.homeTextFill);
  }

  static TextStyle homeScreenTextStroke() {
    return GoogleFonts.chewy(
      fontSize: 59,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = AppColors.homeTextStroke,
    );
  }

  static TextStyle primaryText() {
    return GoogleFonts.freeman(fontSize: 30, color: AppColors.primaryText);
  }

  static TextStyle splashText() {
    return GoogleFonts.fredoka(
      fontSize: 58,
      fontWeight: FontWeight.w700,
      color: AppColors.splashText,
    );
  }
}
