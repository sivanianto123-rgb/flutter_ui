import 'package:ecommerce_app/screens/detail_screen.dart';
import 'package:ecommerce_app/styles/fonts.dart';
import 'package:flutter/material.dart';

class PlaceCard extends StatelessWidget {
  final String image;
  final String title;
  final String rating;
  const PlaceCard({
    super.key,
    required this.image,
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailScreen(image: image, title: title, rating: rating),
          ),
        );
      },
      child: Container(
        width: 188,
        height: 240,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(top: 186, left: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(image: AssetImage(image)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              width: 90,
              height: 23,
              decoration: BoxDecoration(
                color: Color(0xFF4D5652),
                borderRadius: BorderRadius.circular(59),
              ),
              child: Text('Alley Palace', style: AppFonts.w400w12),
            ),
            SizedBox(height: 6),
            Container(
              height: 24,
              width: 52,

              decoration: BoxDecoration(
                color: Color(0xFF4D5652),
                borderRadius: BorderRadius.circular(59),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 2, top: 1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.star, color: Color(0xFFF8D675), size: 18),
                    SizedBox(width: 2),
                    Text(rating, style: AppFonts.w400w12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
