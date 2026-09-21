import 'package:flutter/material.dart';
import '../../styles/fonts.dart';

class ProductInfoSection extends StatelessWidget {
  final String name;
  final String category;
  final double price;

  const ProductInfoSection({
    super.key,
    required this.name,
    required this.category,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: AppFonts.w400g13),
                SizedBox(height: 5),
                Text(name, style: AppFonts.w600b22),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Price', style: AppFonts.w400g13),
              SizedBox(height: 5),
              Text('\$${price.toInt()}', style: AppFonts.w600b22),
            ],
          ),
        ],
      ),
    );
  }
}
