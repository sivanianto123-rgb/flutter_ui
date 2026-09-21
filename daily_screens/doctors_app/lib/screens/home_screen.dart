import 'package:docters_app/utils/colors/colors.dart';
import 'package:docters_app/widgets/app_bar.dart/custom_app_bar.dart';
import 'package:docters_app/widgets/doctors_list/doctors_list.dart';
import 'package:docters_app/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:docters_app/screens/doctors_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/date_picker/date_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondarytextcolor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(),
              SizedBox(height: 13),
              DatePicker(),
              SizedBox(height: 15),
              DoctorsList(
                onDoctorTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorsScreen()),
                  );
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DoctorsScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
