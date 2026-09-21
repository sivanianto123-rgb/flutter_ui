import 'package:ecommerce_app/widgets/recommended/rec_card.dart';
import 'package:flutter/material.dart';

class RecList extends StatelessWidget {
  const RecList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> places = [
      {
        'image': 'lib/assets/images/alleypalace.png',
        'title': 'Explore Aspen',
        'rating': '4.3',
      },
      {
        'image': 'lib/assets/images/alleypalace.png',
        'title': 'Luxurious Aspen',
        'rating': '4.2',
      },
    ];
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return RecCard(
            image: place['image'],
            title: place['title'],
            rating: place['rating'],
          );
        },
      ),
    );
  }
}
