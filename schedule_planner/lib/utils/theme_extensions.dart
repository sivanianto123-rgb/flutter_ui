import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../styles/app_colors.dart';

extension BuildContextX on BuildContext {
  bool get isDark => watch<ThemeProvider>().isDark;
  Color get bg => isDark ? AppColors.black : AppColors.lightBg;
  Color get card => isDark ? AppColors.cardBg : AppColors.lightCard;
  Color get dividerC => isDark ? AppColors.divider : AppColors.lightDivider;
  Color get completedC => isDark ? AppColors.completed : AppColors.lightCompleted;
}
