import 'package:flutter/material.dart';
import 'package:profile_app/styles/colors/colors.dart';
import 'package:profile_app/styles/fonts/fonts.dart';

class Jobs extends StatefulWidget {
  const Jobs({super.key});

  @override
  State<Jobs> createState() => _JobsState();
}

class _JobsState extends State<Jobs> {
  int _currentPage = 0;

  final List<String> jobsDone = [
    'Product\nDesign',
    'Front end',
    'Visual\nDesigner',
    'Voyager',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Jobs done', style: AppFonts.w500b16),

        SizedBox(height: 16),

        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: jobsDone.length,
            itemBuilder: (context, index) {
              return _buildJobCard(jobsDone[index]);
            },
          ),
        ),

        SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == 0
                    ? AppColors.secondarycolor
                    : AppColors.secondarycolor.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard(String title) {
    return Container(
      width: 90,
      height: 90,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.w500r14,
        ),
      ),
    );
  }
}
