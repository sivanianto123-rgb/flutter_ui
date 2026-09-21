import 'package:flutter/material.dart';
import 'package:bankapp/pages/homepage.dart';
import 'package:bankapp/pages/mycard.dart';
import 'package:bankapp/pages/statistics.dart';
import 'package:bankapp/pages/settings.dart';
import 'package:bankapp/pages/bottomnavbar.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavBarTap(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: [HomePage(), MyCardPage(), StatisticsPage(), SettingsPage()],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
