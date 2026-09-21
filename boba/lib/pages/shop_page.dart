import 'package:boba/comp/drink_tile.dart';
import 'package:boba/models/drink.dart';
import 'package:boba/models/shop.dart';
import 'package:boba/pages/order_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Consumer;

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  //to go to orders
  void goToOrderPage(Drink drink) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderPage(drink: drink)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BubbleTeaShop>(
      builder:
          (context, value, child) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  // intro
                  Text(' BOBAAAAAA', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  // lists drinks
                  Expanded(
                    child: ListView.builder(
                      itemCount: value.shop.length,
                      itemBuilder: (context, index) {
                        // get indi

                        Drink individualDrink = value.shop[index];

                        //return drink as listss
                        return DrinkTile(
                          drink: individualDrink,
                          onTap: () => goToOrderPage(individualDrink),
                          trailing: Icon(Icons.arrow_forward),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
