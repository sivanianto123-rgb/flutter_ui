import 'package:flutter/material.dart';
import 'package:watch_app/widgets/collections/collections_list/collections_card.dart';

import '../../../screens/description_screen.dart';

class CollectionsList extends StatelessWidget {
  const CollectionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'image': 'lib/assets/images/watch.png',
        'name': 'CALENDAR ULTRA-THIN',
        'price': '84,000',
      },
      {
        'image': 'lib/assets/images/watch.png',
        'name': 'PATRM SELF-WINDING',
        'price': '38,800',
      },
    ];

    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return CollectionsCard(
            imagePath: item['image']!,
            name: item['name']!,
            price: item['price']!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DescriptionScreen(
                    imagePath: item['image']!,
                    name: item['name']!,
                    price: item['price']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
