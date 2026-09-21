import 'package:flutter/material.dart';

/// Bright, vibrant kid-friendly color palette for Mave 3.
class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color background    = Color(0xFF1A1A2E); // Deep night sky
  static const Color backgroundAlt = Color(0xFF16213E);
  static const Color skyTop        = Color(0xFF0F3460); // Deeper sky
  static const Color skyBottom     = Color(0xFF533483); // Purple dusk

  // ── Brand / node colors ──────────────────────────────────────────────────────
  static const Color primary       = Color(0xFFFF6B6B); // Bright coral-red
  static const Color primaryLight  = Color(0xFFFF9A9E);
  static const Color secondary     = Color(0xFF4ECDC4); // Vibrant teal
  static const Color secondaryLight= Color(0xFF9BE8E4);
  static const Color accent        = Color(0xFFFFE66D); // Bright yellow
  static const Color accentGreen   = Color(0xFF6BCB77); // Vivid green
  static const Color accentPurple  = Color(0xFFA855F7); // Electric purple
  static const Color accentOrange  = Color(0xFFFF9F43); // Bright orange

  // ── Node-specific colors ────────────────────────────────────────────────────
  static const Color maNodeColor   = Color(0xFFFF6B6B); // Red-coral for Ma
  static const Color paNodeColor   = Color(0xFF4ECDC4); // Teal for Pa
  static const Color comboColor    = Color(0xFFFFE66D); // Gold for combo

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textDark      = Color(0xFF1A1A2E);
  static const Color textMedium    = Color(0xFF4A4A6A);
  static const Color textLight     = Color(0xFF9898B8);
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // ── UI elements ───────────────────────────────────────────────────────────────
  static const Color cardWhite     = Color(0xFFFFFFFF);
  static const Color correctGreen  = Color(0xFF6BCB77);
  static const Color wrongRed      = Color(0xFFFF6B6B);
  static const Color lockedGray    = Color(0xFF6B6B8A);
  static const Color pathColor     = Color(0xFFFFE66D);
  static const Color pathShadow    = Color(0xFFE6C84A);

  // ── Bubble colors ─────────────────────────────────────────────────────────────
  static const List<Color> bubbleColors = [
    Color(0xFFFF6B9D), // Hot pink
    Color(0xFF45B7D1), // Sky blue
    Color(0xFF96E6A1), // Mint
    Color(0xFFFFBE76), // Peach
    Color(0xFFA29BFE), // Lavender
    Color(0xFFFD79A8), // Rose
    Color(0xFF74B9FF), // Light blue
    Color(0xFF55EFC4), // Aquamarine
  ];

  // ── Star / decoration colors ──────────────────────────────────────────────────
  static const Color starGold      = Color(0xFFFFD700);
  static const Color starSilver    = Color(0xFFC0C0C0);
  static const Color cloudWhite    = Color(0xFFF8F9FA);
  static const Color grassGreen    = Color(0xFF2ECC71);
  static const Color darkGrass     = Color(0xFF27AE60);

  // ── Game backgrounds ─────────────────────────────────────────────────────────
  static const Color gameBackground1 = Color(0xFFFFF0F4); // Soft pink for feed monster
  static const Color gameBackground2 = Color(0xFFE8F5FF); // Light blue for bubble hunt
  static const Color gameBackground3 = Color(0xFFF0FFF4); // Pale green for tracing
  static const Color gameBackground4 = Color(0xFFFFFBE6); // Cream for storybook
}
