import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

import '../styles/colors/colors.dart';
import '../styles/fonts/fonts.dart';
import '../widgets/activities_tile.dart';
import '../widgets/campaingntile.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi,', style: AppFonts.w600w14),
              Text('@DuozhuaMiao', style: AppFonts.w600w18),
              SizedBox(height: 20),
              TitledProgressBar(
                maxSteps: 100,
                currentStep: 75,
                progressColor: AppColors.secondarycol0r,
                backgroundColor: Color(0xFF6B6A69),
                labelType: LabelType.percentage,
                labelColor: Colors.black,
                labelFontWeight: FontWeight.bold,
                minHeight: 15,
                borderRadius: BorderRadius.circular(14),
              ),
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.only(top: 20, left: 20),
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Campaign', style: AppFonts.w600b16),
                        SizedBox(width: 200),
                        Image(image: AssetImage('lib/assets/images/star.png')),
                      ],
                    ),
                    Text('Cottage town Inwood', style: AppFonts.w500b10),
                    SizedBox(height: 15),
                    Campaingntile(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ActivitiesTile(),
              SizedBox(height: 45),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.secondarycol0r,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifications(5)', style: AppFonts.w500b14),
                      SizedBox(width: 220),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
