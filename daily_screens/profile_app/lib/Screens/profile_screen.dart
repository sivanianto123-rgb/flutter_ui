import 'package:flutter/material.dart';
import 'package:profile_app/styles/colors/colors.dart';
import 'package:profile_app/styles/fonts/fonts.dart';
import '../widgets/jobs.dart';
import '../widgets/stats.dart';

class ProfileScreen extends StatelessWidget {
  final String imagePath;
  final String name;

  const ProfileScreen({super.key, required this.imagePath, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                      ),
                      Text('Profile', style: AppFonts.w500b16),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primarycolor,
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage(imagePath),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            name.replaceAll('\n', ' '),
                            style: AppFonts.w500b20,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      SizedBox(width: 24),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Profession', style: AppFonts.w500b13),
                                SizedBox(height: 2),
                                Text('Contractor', style: AppFonts.w500r14),
                              ],
                            ),

                            SizedBox(height: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Contact', style: AppFonts.w500b13),
                                SizedBox(height: 2),
                                Text(
                                  '+234 808 2344 4675',
                                  style: AppFonts.w500r14,
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location', style: AppFonts.w500b13),
                                SizedBox(height: 2),
                                Text('Lagos', style: AppFonts.w500r14),
                              ],
                            ),

                            SizedBox(height: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Position', style: AppFonts.w500b13),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: AppColors.secondarycolor,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 4),
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('open', style: AppFonts.w500r14),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            Jobs(),

            SizedBox(height: 24),

            Expanded(child: Stats()),
          ],
        ),
      ),
    );
  }
}
