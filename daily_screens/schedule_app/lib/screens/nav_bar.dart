import 'package:flutter/material.dart';
import 'package:schedule_app/screens/home_screen.dart';
import 'package:schedule_app/screens/schedule_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ScheduleScreen(),
    Center(child: Text('Chat')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 80,
        color: Color(0xFFF5F5F5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _icon(Icons.home_outlined, 0),
            _icon(Icons.calendar_today_outlined, 1),
            _icon(Icons.chat_bubble_outline, 2),
            _icon(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  Widget _icon(IconData icon, int index) {
    bool active = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: active ? const Color(0xFFFF6B4A) : const Color(0xFFBCC1CD),
          ),
          SizedBox(height: 4),
          if (active)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF6B4A),
              ),
            ),
        ],
      ),
    );
  }
}
