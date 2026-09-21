import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles/colors.dart';

class AgeSelector extends StatelessWidget {
  final int age;
  final Function(int) onAgeChanged;

  const AgeSelector({super.key, required this.age, required this.onAgeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 189,
      decoration: BoxDecoration(
        color: AppColors.secondarycolor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Age',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.secondarytextcolor,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            age.toString(),
            style: GoogleFonts.inter(
              fontSize: 50,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'age_minus',
                onPressed: () {
                  if (age > 0) {
                    onAgeChanged(age - 1);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                backgroundColor: const Color(0xFF8B8C9E),
                mini: true,
                child: const Icon(Icons.remove, color: Colors.white),
              ),
              const SizedBox(width: 15),
              FloatingActionButton(
                heroTag: 'age_plus',
                onPressed: () {
                  onAgeChanged(age + 1);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                backgroundColor: const Color(0xFF8B8C9E),
                mini: true,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
