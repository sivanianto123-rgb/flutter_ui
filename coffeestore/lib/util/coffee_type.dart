import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoffeeType extends StatelessWidget {
  final String coffeType;
  final bool isSelected;
  final Function onTap; 

  const CoffeeType({
    super.key,
    required this.coffeType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(), 
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0),
        child: Text(
          coffeType,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.deepOrangeAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}
