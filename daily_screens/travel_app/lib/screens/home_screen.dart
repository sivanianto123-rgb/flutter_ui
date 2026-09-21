import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/widgets/nav_bar.dart';
import 'package:travel_app/widgets/place_list.dart';

import '../widgets/category_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey David',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Explore the world',
                        style: GoogleFonts.montserrat(
                          color: Color(0xFF888888),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('lib/assets/images/men.png'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 58,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search places',
                          hintStyle: GoogleFonts.montserrat(
                            color: Color(0xFf888888),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.tune,
                        color: Color(0xFF888888),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    'Popular Places',
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 130),
                  Text(
                    'View all',
                    style: GoogleFonts.montserrat(
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Category_list(),
              SizedBox(height: 30),
              Expanded(child: PlaceList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
