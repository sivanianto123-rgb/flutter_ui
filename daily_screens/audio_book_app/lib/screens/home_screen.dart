import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../widgets/brand_list.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/home_widgets/custom_search_bar.dart';
import '../widgets/home_widgets/greetings.dart';
import '../widgets/home_widgets/home_header.dart';
import '../widgets/new_arrivals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    HomeHeader(),
                    SizedBox(height: 25),
                    GreetingSection(),
                    SizedBox(height: 20),
                    SearchBarWidget(),
                    SizedBox(height: 25),
                    BrandListSection(),
                    SizedBox(height: 25),
                    NewArrivalsSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            CustomBottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }
}
