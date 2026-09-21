import 'package:coffee_app/styles/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 284,
      height: 51,
      decoration: BoxDecoration(
        color: AppColors.secondarycolor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding:  EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.search, color: AppColors.secondarytextcolor),
            SizedBox(width: 20),
            Text(
              'Find your coffee...',
              style: GoogleFonts.roboto(
                color: AppColors.secondarytextcolor,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
