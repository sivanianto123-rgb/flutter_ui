import 'package:docters_app/utils/colors/colors.dart';
import 'package:docters_app/utils/fonts/fonts.dart';
import 'package:flutter/material.dart';

class DoctorsList extends StatelessWidget {
  final VoidCallback? onDoctorTap;

  const DoctorsList({super.key, this.onDoctorTap});

  final List<Map<String, dynamic>> doctors = const [
    {
      'name': 'Dr. Olivia Turner, M.D.',
      'specialty': 'Dermato-Endocrinology',
      'rating': 5.0,
      'reviews': 60,
      'isFavorite': true,
      'image': 'lib/assets/images/p1.png',
    },
    {
      'name': 'Dr. Alexander Bennett, Ph.D.',
      'specialty': 'Dermato-Genetics',
      'rating': 4.5,
      'reviews': 40,
      'isFavorite': false,
      'image': 'lib/assets/images/p2.png',
    },
    {
      'name': 'Dr. Sophia Martinez, Ph.D.',
      'specialty': 'Cosmetic Bioengineering',
      'rating': 5.0,
      'reviews': 150,
      'isFavorite': false,
      'image': 'lib/assets/images/p3.png',
    },
    {
      'name': 'Dr. Michael Davidson, M.D.',
      'specialty': 'Nano-Dermatology',
      'rating': 4.8,
      'reviews': 90,
      'isFavorite': true,
      'image': 'lib/assets/images/p4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: doctors.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: onDoctorTap,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarycolor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(doctors[index]['image']),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctors[index]['name'], style: AppFonts.w500b14),
                      SizedBox(height: 4),
                      Text(
                        doctors[index]['specialty'],
                        style: AppFonts.w400b12,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            doctors[index]['rating'] == 5.0
                                ? Icons.star
                                : Icons.star_border,
                            size: 18,
                            color: AppColors.secondarycolor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            doctors[index]['rating'].toString(),
                            style: AppFonts.w400b12,
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: AppColors.secondarycolor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            doctors[index]['reviews'].toString(),
                            style: AppFonts.w400b12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondarycolor),
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondarycolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondarycolor),
                      ),
                      child: Icon(
                        doctors[index]['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: AppColors.secondarycolor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
