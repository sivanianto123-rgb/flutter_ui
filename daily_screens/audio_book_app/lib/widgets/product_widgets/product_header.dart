import 'package:flutter/material.dart';
import '../../styles/colors.dart';

class ProductDetailHeader extends StatelessWidget {
  final VoidCallback onBackTap;

  const ProductDetailHeader({super.key, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
