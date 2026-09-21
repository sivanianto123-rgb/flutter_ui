import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

class AppDividers {
  static const Widget dark = Divider(
    color: AppColors.divider,
    thickness: 1,
    height: 1,
  );

  static Widget section = const Divider(
    color: AppColors.darkGrey,
    thickness: 1,
    height: 24,
  );
}
