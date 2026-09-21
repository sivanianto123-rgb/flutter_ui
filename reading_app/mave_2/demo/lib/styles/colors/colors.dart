import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF4A3B6B);
  static const Color deepPurple = Color(0xFF2D2445);
  static const Color lightPurple = Color(0xFF6B5B8E);
  static const Color accentPurple = Color(0xFF8B7BA8);

  static const Color planetPink = Color(0xFF8B4572);
  static const Color planetPurple = Color(0xFF5C4B7A);

  static const Color cloudLight = Color(0xFFF5F5F5);
  static const Color cloudDark = Color(0xFFB8B0C8);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFE8E4F0);
  static const Color textDark = Color(0xFF2D2445);

  static const Color buttonPrimary = Color(0xFF5BB5C3);
  static const Color buttonSecondary = Color(0xFF6B5B8E);
  static const Color progressGreen = Color(0xFF4CAF50);
  static const Color cardBackground = Color(0xFFF5EDE4);
  static const Color cardBorder = Color(0xFFE8D4C4);

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D2445), Color(0xFF4A3B6B)],
  );

  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1833), Color(0xFF4A3B6B), Color(0xFF6B5B8E)],
  );
}
