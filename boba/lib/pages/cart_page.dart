import 'package:boba/comp/drink_tile.dart';
import 'package:boba/models/drink.dart';
import 'package:boba/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // remove drink from cart
  void removeFromCart(Drink drink) {
    Provider.of<BubbleTeaShop>(context, listen: false).removeFromCart(drink);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BubbleTeaShop>(
      builder:
          (context, value, child) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // title
                  Text('Your Cart', style: TextStyle(fontSize: 20)),

                  // list of cart items
                  Expanded(
                    child: ListView.builder(
                      itemCount: value.cart.length,
                      itemBuilder: (context, index) {
                        // indi drinks
                        Drink drink = value.cart[index];
                        return DrinkTile(
                          drink: drink,
                          onTap: () => removeFromCart(drink),
                          trailing: Icon(Icons.delete),
                        );

                        //return as a nice tile
                      },
                    ),
                  ),

                  // pay button
                  MaterialButton(
                    color: Colors.brown,

                    onPressed: () {},
                    child: Text('PAY', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
