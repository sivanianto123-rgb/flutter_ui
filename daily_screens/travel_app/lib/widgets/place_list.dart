import 'package:flutter/material.dart';
import 'place_card.dart';

class PlaceList extends StatelessWidget {
  const PlaceList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> places = [
      {
        'image': 'lib/assets/images/mount_fuji.png',
        'location': 'Tokyo, Japan',
        'rating': 4.8,
        'price': '350',
        'duration': '8 hours',
        'temperature': '16°C',
        'description':
            'This vast mountain range is renowned for its remarkable diversity in terms of topography and climate. It features towering peaks, active volcanoes, deep canyons, expansive plateaus.',
      },
      {
        'image': 'lib/assets/images/andes.png',
        'title': 'Andes Mountain',
        'location': 'South America',
        'rating': 4.5,
        'price': '230',
        'duration': '6 hours',
        'temperature': '12°C',
        'description':
            'The Andes is the longest continental mountain range in the world. It stretches across seven countries and features diverse ecosystems from tropical rainforests to glaciers.',
      },
      {
        'image': 'lib/assets/images/mount_fuji.png',
        'title': 'Alps Mountain',
        'location': 'Switzerland',
        'rating': 4.9,
        'price': '420',
        'duration': '10 hours',
        'temperature': '8°C',
        'description':
            'The Alps are one of Europe\'s most famous mountain ranges. Known for stunning scenery, world-class skiing, and charming villages nestled in valleys between towering peaks.',
      },
    ];

    return SizedBox(
      height: 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return PlaceCard(
            image: place['image'],
            title: place['title'],
            location: place['location'],
            rating: place['rating'],
            price: place['price'],
            duration: place['duration'],
            temperature: place['temperature'],
            description: place['description'],
          );
        },
      ),
    );
  }
}
