import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../styles/colors.dart';

class Heightselector extends StatelessWidget {
  final Function(int) onHeightChanged;
  final int height;

  const Heightselector({
    super.key,
    required this.onHeightChanged,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 189,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondarycolor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Height',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.secondarytextcolor,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                height.toString(),
                style: GoogleFonts.inter(
                  fontSize: 50,
                  color: AppColors.primarytextcolor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'cm',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: AppColors.secondarytextcolor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.slideractivecolor,
              inactiveTrackColor: AppColors.secondarytextcolor,
              thumbColor: AppColors.slideractivecolor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: height.toDouble(),
              min: 120,
              max: 220,
              onChanged: (value) {
                onHeightChanged(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}
