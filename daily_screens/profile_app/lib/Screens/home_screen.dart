import 'package:flutter/material.dart';
import 'package:profile_app/styles/colors/colors.dart';
import 'package:profile_app/styles/fonts/fonts.dart';

import '../widgets/services.dart';
import '../widgets/tile_1.dart';
import '../widgets/workers_list/workers_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profile', style: AppFonts.w500b16),
                    Icon(Icons.menu_open, color: AppColors.secondarycolor),
                  ],
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primarycolor,
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            'lib/assets/images/profile.png',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adewale Taiwo', style: AppFonts.w500b20),
                          const SizedBox(height: 4),
                          Text('House Manager', style: AppFonts.w500r14),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 34),

                Tile1(),

                SizedBox(height: 29),

                Row(children: [Text('Houses', style: AppFonts.w500b16)]),

                SizedBox(height: 16),

                WorkersList(),

                SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Services', style: AppFonts.w500b16),
                    Text('All', style: AppFonts.w500r16),
                  ],
                ),

                const SizedBox(height: 30),

                Services(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
