import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF74573A);
  static const secondaryColor = Color(0xFF3E3128);
  static const primaytextColor = Colors.white;
  static const contColor = Color(0xFFD9CBB9);

  static const LinearGradient verticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, secondaryColor],
  );
}
