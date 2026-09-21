import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Category_list extends StatefulWidget {
  const Category_list({super.key});

  @override
  State<Category_list> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<Category_list> {
  int selectedIndex = 0;
  final List<String> categories = ['Most Viewed', 'Nearby', 'Latest', 'New'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Color(0xFFFBFBFB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: GoogleFonts.montserrat(
                      color: isSelected ? Colors.white : Color(0xFF999999),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
