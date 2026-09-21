import 'package:bankapp/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/pages/mycard.dart';
import 'package:bankapp/pages/statistics.dart';
import 'package:bankapp/pages/settings.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
    required void Function(int index) onTap,
    required int currentIndex,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MyCardPage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          elevation: 8,
          backgroundColor: ColorConstants.bottomnavbar,
          selectedItemColor: ColorConstants.button,
          unselectedItemColor: ColorConstants.silenttextcolor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          enableFeedback: false, 
          items: [
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(top: 12),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(top: 12),
                child: Icon(Icons.wallet),
              ),
              label: 'My Card',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(top: 12),
                child: Icon(Icons.bar_chart),
              ),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(top: 12),
                child: Icon(Icons.settings),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
