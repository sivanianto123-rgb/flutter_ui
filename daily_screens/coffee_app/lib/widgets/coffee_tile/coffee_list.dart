import 'package:flutter/material.dart';
import '../../screens/order_screen.dart';
import 'coffee_card.dart';

class CoffeeListView extends StatelessWidget {
  const CoffeeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final coffeeItems = [
      {
        'image': 'lib/assets/images/coffee.png',
        'rating': 4.5,
        'title': 'Cappuccino',
        'subtitle': 'With Oat Milk',
        'price': 4.20,
      },
      {
        'image': 'lib/assets/images/coffee.png',
        'rating': 4.8,
        'title': 'Espresso',
        'subtitle': 'With Chocolate',
        'price': 3.50,
      },
      {
        'image': 'lib/assets/images/coffee.png',
        'rating': 4.3,
        'title': 'Latte',
        'subtitle': 'With Milk',
        'price': 4.50,
      },
      {
        'image': 'lib/assets/images/coffee.png',
        'rating': 4.7,
        'title': 'Flat White',
        'subtitle': 'With Oat Milk',
        'price': 4.00,
      },
    ];

    return SizedBox(
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: coffeeItems.length,
        itemBuilder: (context, index) {
          final item = coffeeItems[index];
          return CoffeeCard(
            imagePath: item['image'] as String,
            rating: item['rating'] as double,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            price: item['price'] as double,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderScreen(
                    imagePath: item['image'] as String,
                    rating: item['rating'] as double,
                    title: item['title'] as String,
                    subtitle: item['subtitle'] as String,
                    price: item['price'] as double,
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
