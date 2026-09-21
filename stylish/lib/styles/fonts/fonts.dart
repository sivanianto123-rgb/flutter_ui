import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylish/styles/colors/colors.dart';

class FontStyles {
  // Title Text Style
  static TextStyle title = GoogleFonts.montserrat(
    fontSize: 24.0,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  // Description Text Style
  static TextStyle description = GoogleFonts.montserrat(
    fontSize: 14.0,
    color: ColorsConstants.unselectedtext,
  );

  // Step Counter Selected Text Style
  static TextStyle stepCounterSelected = GoogleFonts.montserrat(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Step Counter Unselected Text Style
  static TextStyle stepCounterUnselected = GoogleFonts.montserrat(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: ColorsConstants.unselectedtext,
  );

  // Button Text Style (Default Button)
  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Button Text Style (Primary Button)
  static TextStyle buttonPrimary = GoogleFonts.montserrat(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: ColorsConstants.primarycolor,
  );

  // Button Text Style (Unselected)
  static TextStyle buttonUnselected = GoogleFonts.montserrat(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: ColorsConstants.unselectedtext,
  );
}
