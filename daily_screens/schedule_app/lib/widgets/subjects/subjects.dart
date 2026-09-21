import 'package:flutter/material.dart';
import 'package:schedule_app/styles/fonts/fonts.dart';

import 'subject_card.dart';

class Subjects extends StatelessWidget {
  const Subjects({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0, top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subjects', style: AppFonts.w800b24),
          SizedBox(height: 2),
          Text('Recommendations for you', style: AppFonts.w400g14),
          SizedBox(height: 16),
          Row(
            children: [
              SubjectCard(
                title: 'Mathematics',
                iconPath: 'lib/assets/images/root.png',
                baseColor: Color(0xFFFF7648),
                blobColor: Color(0xFFFFC278),
              ),
              SizedBox(width: 10),
              SubjectCard(
                title: 'Geography',
                iconPath: 'lib/assets/images/earth.png',
                baseColor: Color(0xFF8B7BF7),
                blobColor: Color(0xFF3D3A8C),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
