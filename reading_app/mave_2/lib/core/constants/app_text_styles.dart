import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayHuge = TextStyle(
    fontSize: 120,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: -2,
    height: 1.0,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: -1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.6,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );

  static const TextStyle storyText = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.7,
  );

  static TextStyle letterBlock = const TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
    letterSpacing: 0,
  );
}
