import 'package:flutter/material.dart';

import '../../styles/fonts.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello', style: AppFonts.w600b28),
          SizedBox(height: 4),
          Text('Welcome to Laza.', style: AppFonts.w400g15),
        ],
      ),
    );
  }
}
