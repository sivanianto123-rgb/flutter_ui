import 'dart:math';
import 'dart:ui';

class BMICalculator {
  final int height;
  final int weight;

  BMICalculator({required this.height, required this.weight});

  double calculateBMI() {
    double heightInMeters = height / 100;
    double bmi = weight / pow(heightInMeters, 2);
    return bmi;
  }

  String getResult(double bmi) {
    if (bmi >= 25) {
      return 'Overweight';
    } else if (bmi > 18.5) {
      return 'Normal';
    } else {
      return 'Underweight';
    }
  }

  String getInterpretation(double bmi) {
    if (bmi >= 25) {
      return 'You have a higher than normal body weight. Try to exercise more.';
    } else if (bmi > 18.5) {
      return 'You have a normal body weight. Good job!';
    } else {
      return 'You have a lower than normal body weight. You should eat more.';
    }
  }

  Color getResultColor(double bmi) {
    if (bmi >= 25) {
      return const Color(0xFFEB1555);
    } else if (bmi > 18.5) {
      return const Color(0xFF24D876);
    } else {
      return const Color(0xFFEAA400);
    }
  }
}
