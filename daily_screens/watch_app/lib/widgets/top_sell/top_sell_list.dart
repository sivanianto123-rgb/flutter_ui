import 'package:flutter/material.dart';
import 'package:watch_app/widgets/top_sell/top_sell_card.dart';

import '../../../screens/description_screen.dart';

class TopSellList extends StatelessWidget {
  const TopSellList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'image': 'lib/assets/images/watch.png',
        'name': 'EGERIE MOON PHASE',
        'price': '36,200',
        'originalPrice': '56,200',
      },
      {
        'image': 'lib/assets/images/watch.png',
        'name': 'COMPLETE CALEN OPENFACE',
        'price': '47,300',
        'originalPrice': '77,300',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TopSellCard(
          imagePath: item['image']!,
          name: item['name']!,
          price: item['price']!,
          originalPrice: item['originalPrice']!,
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
    );
  }
}
