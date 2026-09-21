import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
  return Container(
 padding: const EdgeInsets.only(top: 8),
  child: BottomNavigationBar(
  currentIndex: 2,
  backgroundColor: Colors.white,
  selectedItemColor: Colors.deepOrangeAccent,

   type: BottomNavigationBarType.fixed,
   showSelectedLabels: false,
    showUnselectedLabels: false,
   items: const [
   BottomNavigationBarItem(
   icon: Icon(Icons.home_outlined),
     label: 'Home',
),
     BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
           label: 'cart',
),
    BottomNavigationBarItem(
  icon: Icon(Icons.message_outlined),
   label: 'Settings',
),
   BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
],
),
    );}}
