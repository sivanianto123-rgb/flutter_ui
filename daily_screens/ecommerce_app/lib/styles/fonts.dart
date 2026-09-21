import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextStyle getAppFont({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.montserrat(
      textStyle: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static final w400b14 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Colors.black,
  );
  static final w500b32 = getAppFont(
    fontWeight: FontWeight.w500,
    fontSize: 32,
    color: Colors.black,
  );
  static final w400g13 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: Color(0xFFB8B8B8),
  );
  static final w400w12 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: Colors.white,
  );
  static final w600b18 = getAppFont(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: Colors.black,
  );
  static final w400g10 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 10,
    color: Color(0xFFB8B8B8),
  );
  static final w600g18 = getAppFont(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: Color(0xFFFFFFFF),
  );
}
