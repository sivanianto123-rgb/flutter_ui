import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectionTypes extends StatefulWidget {
  const CollectionTypes({super.key});

  @override
  State<CollectionTypes> createState() => _CollectionTypes();
}

class _CollectionTypes extends State<CollectionTypes> {
  int selectedIndex = 1;
  final List<String> categories = [
    'Patrimony',
    'Traditionnelle',
    'Fiftysix',
    'Overseas',
  ];

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
                height: 34,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFA6978B)),
                  color: Color(0xFF8A796B),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.white,
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
