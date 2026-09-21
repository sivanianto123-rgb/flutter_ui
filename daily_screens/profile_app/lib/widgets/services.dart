import 'package:flutter/material.dart';
import '../styles/colors/colors.dart';
import '../styles/fonts/fonts.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 356,
            height: 93,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.man_2, color: AppColors.secondarycolor, size: 40),
                SizedBox(width: 12),
                Text('Electrical', style: AppFonts.w500b20),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        Center(
          child: Container(
            width: 356,
            height: 93,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.devices_other,
                  color: AppColors.secondarycolor,
                  size: 40,
                ),
                SizedBox(width: 12),
                Text('Others', style: AppFonts.w500b20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
