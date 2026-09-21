import 'package:flutter/material.dart';
import '../styles/colors/colors.dart';
import '../styles/fonts/fonts.dart';

class Tile1 extends StatelessWidget {
  const Tile1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            width: 152,
            height: 179,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.primarycolor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Wallet Balance:', style: AppFonts.w500b11),
                SizedBox(height: 4),
                Text('\$5046.57', style: AppFonts.w600r19),
                SizedBox(height: 16),
                Text('Total Service', style: AppFonts.w500b11),
                SizedBox(height: 2),
                Text('25', style: AppFonts.w600r19),
              ],
            ),
          ),

          SizedBox(width: 30),

          Container(
            padding: EdgeInsets.all(16),
            width: 152,
            height: 179,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.secondarycolor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Master Card', style: AppFonts.w500w11),
                SizedBox(height: 13),
                Text(
                  '5999-XXXX\nAdewale T.',
                  textAlign: TextAlign.center,
                  style: AppFonts.w600w15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
