import 'package:flutter/material.dart';

import '../styles/fonts.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: AppFonts.w600b17),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: AppFonts.w400g15,
              children: [
                TextSpan(
                  text:
                      'The Nike Throwback Pullover Hoodie is made from premium French terry fabric that blends a performance feel with',
                ),
                TextSpan(
                  text: ' Read More..',
                  style: AppFonts.w400b15.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
