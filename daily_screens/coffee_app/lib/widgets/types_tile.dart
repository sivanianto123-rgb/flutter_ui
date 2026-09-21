import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TypesTile extends StatefulWidget {
  const TypesTile({super.key});

  @override
  State<TypesTile> createState() => _TypesTileState();
}

class _TypesTileState extends State<TypesTile> {
  int selectedIndex = 0;
  final List<String> categories = [
    'Cappuccino',
    'Espresso',
    'Latte',
    'Flat coffee',
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
            padding:  EdgeInsets.only(right: 36),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categories[index],
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Color(0xFFC67C4E) : Color(0xFF9B9B9B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFFC67C4E)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
