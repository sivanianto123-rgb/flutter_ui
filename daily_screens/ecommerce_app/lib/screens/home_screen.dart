import 'package:ecommerce_app/styles/fonts.dart';
import 'package:ecommerce_app/widgets/categories_list.dart';
import 'package:ecommerce_app/widgets/places/places_list.dart';
import 'package:ecommerce_app/widgets/recommended/rec_list.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_search_bar.dart';
import '../widgets/nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 44, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    Text('Explore', style: AppFonts.w400b14),
                    SizedBox(width: 174),

                    Icon(Icons.location_on, color: Color(0xFF186FF0)),
                    SizedBox(width: 4),

                    Text('Aspen,', style: AppFonts.w400b14),
                    Text(' USA', style: AppFonts.w400b14),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
                Text('Aspen', style: AppFonts.w500b32),
                SizedBox(height: 24),
                CustomSearchBar(),
                SizedBox(height: 32),
                Category_list(),
                SizedBox(height: 32),
                Text('Popular', style: AppFonts.w600b18),
                PlacesList(),
                Text('Recommended', style: AppFonts.w600b18),
                RecList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavbar(),
    );
  }
}
