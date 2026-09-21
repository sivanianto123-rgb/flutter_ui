import 'package:coffee_app/styles/colors/colors.dart';
import 'package:coffee_app/widgets/bottom_navbar.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/coffee_tile/coffee_list.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/types_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.menu_rounded, color: Colors.white),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(
                      'lib/assets/images/profile.png',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),
              Text(
                'Find the best\ncoffee for you',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 28),
              CustomSearchBar(),
              SizedBox(height: 25),

              TypesTile(),
              SizedBox(height: 21),
              CoffeeListView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
