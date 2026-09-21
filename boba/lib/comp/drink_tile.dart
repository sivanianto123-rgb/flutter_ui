import 'package:boba/models/drink.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DrinkTile extends StatelessWidget {
  final Drink drink;
  void Function()? onTap;
  final Widget trailing;
  DrinkTile({
    super.key,
    required this.drink,
    required this.onTap,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(drink.name),
              subtitle: Text(drink.price),
              leading: Image.asset(drink.imagepath),
              trailing: trailing,
            ),
          ),
        );
      },
    );
  }
}
