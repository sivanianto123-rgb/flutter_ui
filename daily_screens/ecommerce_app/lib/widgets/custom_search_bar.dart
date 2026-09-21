import 'package:ecommerce_app/styles/fonts.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF3F8FE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.search, color: Color(0xFFB8B8B8)),
          Text('Find things to do', style: AppFonts.w400g13),
        ],
      ),
    );
  }
}
