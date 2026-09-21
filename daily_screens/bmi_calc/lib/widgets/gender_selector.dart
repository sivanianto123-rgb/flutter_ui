import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../styles/colors.dart';

class GenderSelector extends StatefulWidget {
  const GenderSelector({super.key});

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String? selectedGender;

  Widget buildGenderCard(String gender, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        width: 155,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.secondarycolor,
          border: selectedGender == gender
              ? Border.all(color: AppColors.primarytextcolor, width: 3)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 90, fit: BoxFit.contain),
            const SizedBox(height: 15),
            Text(
              gender,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.secondarytextcolor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildGenderCard('Male', 'lib/assets/images/male.png'),
        const SizedBox(width: 20),
        buildGenderCard('Female', 'lib/assets/images/female.png'),
      ],
    );
  }
}
