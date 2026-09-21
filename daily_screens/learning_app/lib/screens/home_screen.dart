import 'package:flutter/material.dart';
import 'package:learning_app/styles/colors/colors.dart';
import 'package:learning_app/styles/fonts/fonts.dart';
import 'package:learning_app/widgets/choice_tile.dart';
import 'package:learning_app/widgets/lesson_tile.dart';
import 'package:learning_app/widgets/scroll_tile.dart';

import '../widgets/search_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarycolor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.menu, size: 32),
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(
                      'lib/assets/images/profile.png',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text('Hello Pann!', style: AppFonts.w700primaryText32),
              SizedBox(height: 2),
              Text(
                'what do you want to learn ?',
                style: AppFonts.w400primaryText16,
              ),
              SizedBox(height: 10),
              CustomSearchBar(),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(18),
                width: double.infinity,

                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFF366F81),

                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 5,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                      color: Color(0xFF4EA3B9),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Course!', style: AppFonts.w700primaryText24),
                    SizedBox(height: 2),
                    Text(
                      'Photography Class',
                      style: AppFonts.w700primaryText15,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 105,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF7ACFFF),
                      ),
                      child: Center(
                        child: Text(
                          'See Class',
                          style: AppFonts.w700primaryText18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 21),
              ChoiceTile(),
              SizedBox(height: 13),
              ScrollTile(),
              SizedBox(height: 13),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LessonsTile(
                        title: 'UI Design - Mobile APP',
                        image: 'lib/assets/images/laptop.png',
                        rating: 4.5,
                        duration: '4h, 26min',
                      ),
                      LessonsTile(
                        title: '3D Design with Blender',
                        image: 'lib/assets/images/desk.png',
                        rating: 3.5,
                        duration: '2h, 44min',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
