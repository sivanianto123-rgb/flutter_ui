import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watch_app/styles/colors/colors.dart';
import 'package:watch_app/widgets/collections/collections.dart';
import 'package:watch_app/widgets/top_sell/top_sell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppColors.verticalGradient),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.menu_sharp,
                        size: 30,
                        color: AppColors.primaytextColor,
                      ),
                      Text(
                        'WATCHES',
                        style: GoogleFonts.lora(
                          color: AppColors.primaytextColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.search,
                        size: 30,
                        color: AppColors.primaytextColor,
                      ),
                    ],
                  ),
                  Divider(
                    color: Color(0xFF8A796B),
                    indent: 0.0,
                    endIndent: 0.0,
                    height: 26,
                  ),
                  Collections(),
                  SizedBox(height: 20),
                  TopSell(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
