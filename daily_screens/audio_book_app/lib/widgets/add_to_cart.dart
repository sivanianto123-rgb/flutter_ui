import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../styles/fonts.dart';

class AddToCartBar extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onAddToCart;

  const AddToCartBar({
    super.key,
    required this.totalPrice,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price', style: AppFonts.w400g13),
                  SizedBox(height: 4),
                  Text('with VAT,SD', style: AppFonts.w400g11),
                ],
              ),
              Text('\$${totalPrice.toInt()}', style: AppFonts.w600b22),
            ],
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: onAddToCart,
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('Add to Cart', style: AppFonts.w500w17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
