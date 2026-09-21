import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../styles/colors.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/age_selecctor.dart';
import '../widgets/gender_selector.dart';
import '../widgets/height_selector.dart';
import '../widgets/weight_selector.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomepageState();
}

class _HomepageState extends State<HomeScreen> {
  int height = 150;
  int weight = 60;
  int age = 26;

  void updateHeight(int newHeight) {
    setState(() {
      height = newHeight;
    });
  }

  void updateWeight(int newWeight) {
    setState(() {
      weight = newWeight;
    });
  }

  void updateAge(int newAge) {
    setState(() {
      age = newAge;
    });
  }

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
                children: [
                  const GenderSelector(),
                  const SizedBox(height: 20),
                  Heightselector(onHeightChanged: updateHeight, height: height),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: WeightSelector(
                          onWeightChanged: updateWeight,
                          weight: weight,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: AgeSelector(onAgeChanged: updateAge, age: age),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              BMICalculator calc = BMICalculator(
                height: height,
                weight: weight,
              );
              double bmi = calc.calculateBMI();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    bmiValue: bmi,
                    resultText: calc.getResult(bmi),
                    interpretation: calc.getInterpretation(bmi),
                    resultColor: calc.getResultColor(bmi),
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 80,
              color: AppColors.slideractivecolor,
              child: Center(
                child: Text(
                  'Calculate',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
