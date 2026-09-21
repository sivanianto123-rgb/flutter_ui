import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles/colors.dart';

class ResultScreen extends StatelessWidget {
  final double bmiValue;
  final String resultText;
  final String interpretation;
  final Color resultColor;

  const ResultScreen({
    super.key,
    required this.bmiValue,
    required this.resultText,
    required this.interpretation,
    required this.resultColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      appBar: AppBar(
        backgroundColor: AppColors.secondarycolor,
        elevation: 10,
        shadowColor: Colors.black,
        title: Text(
          'BMI Calculator',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primarytextcolor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Result',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.secondarycolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            resultText.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: resultColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            bmiValue.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 100,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primarytextcolor,
                            ),
                          ),
                          SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              interpretation,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                                color: AppColors.secondarytextcolor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 80,
              color: AppColors.slideractivecolor,
              child: Center(
                child: Text(
                  'Re - Calculate',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primarytextcolor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
