import 'package:flutter/material.dart';

class AppColors {
  static const Color splashText = Color(0xFF7B8B8D);
  static const Color primaryText = Color(0xFF3A4250);
  static const Color containerBackground = Color(0xFF5BB5C3);
  static const Color secondaryAppColor = Color(0xFFA4D9EB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color moduleCircleFill = Color(0xFF2A3240);
  static const Color moduleCircleStroke = Color(0xFF5BB5C3);
  static const Color moduleBackground = Color(0xFFD4EEF7);
  static const Color progressBarFill = Color(0xFF8FB847);
  static const Color progressBarBackground = Color(0xFF3A4250);
}

class GradientColors {
  static const List<Color> transformGradient = [
    Color(0xFF0A6ECB),
    Color(0xFF85E9FF),
  ];

  static const List<Color> starGradient = [
    Color(0xFFFB9C00),
    Color(0xFFFFFFFF),
  ];

  static const LinearGradient transformLinearGradient = LinearGradient(
    colors: transformGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient starLinearGradient = LinearGradient(
    colors: starGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
