import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScrollTile extends StatefulWidget {
  const ScrollTile({super.key});

  @override
  State<ScrollTile> createState() => _ScrollTileState();
}

class _ScrollTileState extends State<ScrollTile> {
  int selectedIndex = 1;
  final List<String> categories = ['All', 'Design', 'Development', 'Market'];

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
                height: 26,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF366F81) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Color(0xFF2C3E50),
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
