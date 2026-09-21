import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/colors.dart';

class AppFonts {
  static TextStyle getAppFont({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.fredoka(
      textStyle: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static final TextStyle w500primaryText16 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.primaryText,
  );

  static final TextStyle w500splashText16 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.splashText,
  );

  static final TextStyle w500white16 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.white,
  );

  static final TextStyle w400primaryText18 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: AppColors.primaryText,
  );

  static final TextStyle w400splashText18 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: AppColors.splashText,
  );

  static final TextStyle w400white18 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: AppColors.white,
  );

  static final TextStyle w600primaryText36 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 36,
    color: AppColors.primaryText,
  );

  static final TextStyle w600splashText36 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 36,
    color: AppColors.splashText,
  );

  static final TextStyle w600white36 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 36,
    color: AppColors.white,
  );

  static final TextStyle w700primaryText58 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 58,
    color: AppColors.primaryText,
  );

  static final TextStyle w700splashText58 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 58,
    color: AppColors.splashText,
  );

  static final TextStyle w700white58 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 58,
    color: AppColors.white,
  );

  static final TextStyle w700primaryText106 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 106,
    color: AppColors.primaryText,
  );

  static final TextStyle w700splashText106 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 106,
    color: AppColors.splashText,
  );

  static final TextStyle w700white106 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 106,
    color: AppColors.white,
  );

  static final TextStyle boldPrimaryText = getAppFont(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: AppColors.primaryText,
  );

  static final TextStyle boldWhite = getAppFont(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: AppColors.white,
  );

  static final TextStyle w700Apptheme68 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 68,
    color: AppColors.containerBackground,
  );
  static final TextStyle w700Appthemetext58 = getAppFont(
    fontWeight: FontWeight.w700,
    fontSize: 68,
    color: AppColors.containerBackground,
  );
}
