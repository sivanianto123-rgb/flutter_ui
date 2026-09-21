import 'package:ecommerce_app/widgets/places/place_card.dart';
import 'package:flutter/material.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> places = [
      {
        'image': 'lib/assets/images/alleypalace.png',
        'title': 'Alley Palace',
        'rating': '4.1',
      },
      {
        'image': 'lib/assets/images/coeudresalpes.png',
        'title': 'Coeudres Alpes',
        'rating': '4.5',
      },
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
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return PlaceCard(
            image: place['image'],
            title: place['title'],
            rating: place['rating'],
          );
        },
      ),
    );
  }
}
