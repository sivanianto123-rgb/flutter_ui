import 'package:docters_app/utils/colors/colors.dart';
import 'package:docters_app/utils/fonts/fonts.dart';
import 'package:flutter/material.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  int selectedSortIndex = 0;

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Alexander Bennett, Ph.D.',
      'specialty': 'Dermato-Genetics',
      'isFavorite': false,
      'image': 'lib/assets/images/p2.png',
    },
    {
      'name': 'Dr. Michael Davidson, M.D.',
      'specialty': 'Solar Dermatology',
      'isFavorite': false,
      'image': 'lib/assets/images/p4.png',
    },
    {
      'name': 'Dr. Olivia Turner, M.D.',
      'specialty': 'Dermato-Endocrinology',
      'isFavorite': false,
      'image': 'lib/assets/images/p1.png',
    },
    {
      'name': 'Dr. Sophia Martinez, Ph.D.',
      'specialty': 'Cosmetic Bioengineering',
      'isFavorite': false,
      'image': 'lib/assets/images/p3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondarytextcolor,
      appBar: AppBar(
        backgroundColor: AppColors.secondarytextcolor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.secondarycolor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Doctors',
          style: TextStyle(
            color: AppColors.secondarycolor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.secondarycolor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.tune, color: AppColors.secondarycolor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('Sort By', style: AppFonts.w400b12),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => selectedSortIndex = 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedSortIndex == 0
                          ? AppColors.secondarycolor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondarycolor),
                    ),
                    child: Text(
                      'A→Z',
                      style: TextStyle(
                        color: selectedSortIndex == 0
                            ? Colors.white
                            : AppColors.secondarycolor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => selectedSortIndex = 1),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selectedSortIndex == 1
                          ? AppColors.secondarycolor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondarycolor),
                    ),
                    child: Icon(
                      Icons.star_border,
                      size: 16,
                      color: selectedSortIndex == 1
                          ? Colors.white
                          : AppColors.secondarycolor,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => selectedSortIndex = 2),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selectedSortIndex == 2
                          ? AppColors.secondarycolor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondarycolor),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: selectedSortIndex == 2
                          ? Colors.white
                          : AppColors.secondarycolor,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => selectedSortIndex = 3),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selectedSortIndex == 3
                          ? AppColors.secondarycolor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondarycolor),
                    ),
                    child: Icon(
                      Icons.female,
                      size: 16,
                      color: selectedSortIndex == 3
                          ? Colors.white
                          : AppColors.secondarycolor,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => selectedSortIndex = 4),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selectedSortIndex == 4
                          ? AppColors.secondarycolor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondarycolor),
                    ),
                    child: Icon(
                      Icons.male,
                      size: 16,
                      color: selectedSortIndex == 4
                          ? Colors.white
                          : AppColors.secondarycolor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: doctors.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarycolor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(doctors[index]['image']),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctors[index]['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondarycolor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              doctors[index]['specialty'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondarycolor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Info',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondarycolor,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppColors.secondarycolor,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondarycolor,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppColors.secondarycolor,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondarycolor,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 14,
                                    color: AppColors.secondarycolor,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondarycolor,
                                    ),
                                  ),
                                  child: Icon(
                                    doctors[index]['isFavorite']
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 14,
                                    color: AppColors.secondarycolor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
