import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppFonts {
  static bool isDark = true;

  static Color get _txt =>
      isDark ? AppColors.white : const Color(0xFF1A1A1A);
  static Color get _grey =>
      isDark ? AppColors.grey : AppColors.lightGrey;

  static TextStyle get w700w24 => GoogleFonts.poppins(
      fontWeight: FontWeight.w700, color: _txt, fontSize: 24);
  static TextStyle get w600w18 => GoogleFonts.poppins(
      fontWeight: FontWeight.w600, color: _txt, fontSize: 18);
  static TextStyle get w500w16 => GoogleFonts.poppins(
      fontWeight: FontWeight.w500, color: _txt, fontSize: 16);
  static TextStyle get w400w14 => GoogleFonts.poppins(
      fontWeight: FontWeight.w400, color: _txt, fontSize: 14);
  static TextStyle get w400w12 => GoogleFonts.poppins(
      fontWeight: FontWeight.w400, color: _txt, fontSize: 12);

  // Orange variants (unchanged across themes)
  static TextStyle get w600o18 => GoogleFonts.poppins(
      fontWeight: FontWeight.w600, color: AppColors.orange, fontSize: 18);
  static TextStyle get w500o14 => GoogleFonts.poppins(
      fontWeight: FontWeight.w500, color: AppColors.orange, fontSize: 14);
  static TextStyle get w700o20 => GoogleFonts.poppins(
      fontWeight: FontWeight.w700, color: AppColors.orange, fontSize: 20);

  // Grey variants
  static TextStyle get w400g12 => GoogleFonts.poppins(
      fontWeight: FontWeight.w400, color: _grey, fontSize: 12);
  static TextStyle get w400g14 => GoogleFonts.poppins(
      fontWeight: FontWeight.w400, color: _grey, fontSize: 14);
  static TextStyle get w500g14 => GoogleFonts.poppins(
      fontWeight: FontWeight.w500, color: _grey, fontSize: 14);

  // Strikethrough (completed)
  static TextStyle get w400w14Strike => GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        color: _grey,
        fontSize: 14,
        decoration: TextDecoration.lineThrough,
        decorationColor: _grey,
      );
}
