import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayHuge = TextStyle(
    fontSize:   90,
    fontWeight: FontWeight.w900,
    color:      AppColors.textDark,
    height:     1.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize:   42,
    fontWeight: FontWeight.w800,
    color:      AppColors.textDark,
    height:     1.1,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize:   28,
    fontWeight: FontWeight.w800,
    color:      AppColors.textDark,
    height:     1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize:   22,
    fontWeight: FontWeight.w700,
    color:      AppColors.textDark,
    height:     1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize:   18,
    fontWeight: FontWeight.w500,
    color:      AppColors.textDark,
    height:     1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize:   15,
    fontWeight: FontWeight.w400,
    color:      AppColors.textMedium,
    height:     1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize:   12,
    fontWeight: FontWeight.w600,
    color:      AppColors.textLight,
    height:     1.4,
  );
}
