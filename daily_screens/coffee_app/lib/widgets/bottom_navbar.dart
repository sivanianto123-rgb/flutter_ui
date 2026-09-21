import 'package:coffee_app/styles/colors/colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primarycolor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavItem(icon: Icons.home, index: 0),

          SizedBox(width: 53),

          _buildNavItem(icon: Icons.shopping_bag, index: 1),

          SizedBox(width: 53),

          _buildNavItem(icon: Icons.favorite, index: 2),

          SizedBox(width: 53),

          _buildNavItem(icon: Icons.notifications, index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? Color(0xFFC67C4E) : Color(0xFF9B9B9B),
      ),
    );
  }
}
