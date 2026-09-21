import 'package:flutter/material.dart';
import 'package:score_app/styles/colors/colors.dart';
import 'package:score_app/styles/fonts/fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              Row(
                children: [
                  Text('scorelive', style: Mulish.w700w24),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.secondarycolor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
