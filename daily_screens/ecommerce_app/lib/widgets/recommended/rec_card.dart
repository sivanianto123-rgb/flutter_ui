import 'package:ecommerce_app/styles/fonts.dart';
import 'package:flutter/material.dart';

class RecCard extends StatelessWidget {
  final String image;
  final String title;
  final String rating;
  const RecCard({
    super.key,
    required this.image,
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 174,
      height: 142,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFFF4F4F4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 166,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 2),
          Text('Explore Aspen', style: AppFonts.w400b14),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.priority_high_sharp, size: 12),
                SizedBox(width: 2),
                Text('Hot Deal', style: AppFonts.w400g10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
