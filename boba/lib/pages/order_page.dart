import 'package:boba/models/drink.dart';
import 'package:boba/models/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  final Drink drink;
  const OrderPage({super.key, required this.drink});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // customize sweetness
  double sweetValue = 0.5;
  void customizeSweet(double newValue) {
    setState(() {
      sweetValue = newValue;
    });
  }

  double iceValue = 0.5;
  void customizeIce(double newValue) {
    setState(() {
      iceValue = newValue;
    });
  }

  double bobaValue = 0.5;
  void customizeBoba(double newValue) {
    setState(() {
      bobaValue = newValue;
    });
  }

  //sdd to cart
  void addToCart() {
    Provider.of<BubbleTeaShop>(context, listen: false).addToCart(widget.drink);
    // pop this
    Navigator.pop(context);
    // for user
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(title: Text('ur boba added succesfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.drink.name)),
      backgroundColor: Colors.brown[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            //image
            Image.asset(widget.drink.imagepath),

            //custom drinks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sweet', textAlign: TextAlign.start),

                Spacer(),
                Slider(
                  activeColor: Colors.brown,
                  value: sweetValue,
                  label: sweetValue.toString(),
                  divisions: 4,
                  onChanged: (value) => customizeSweet(value),
                ),
              ],
            ),
            // ice
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ice', textAlign: TextAlign.start),
                Spacer(),
                Slider(
                  activeColor: Colors.brown,
                  value: iceValue,
                  label: sweetValue.toString(),
                  divisions: 4,
                  onChanged: (value) => customizeIce(value),
                ),
              ],
            ),

            //boba
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('boba', textAlign: TextAlign.start),
                Spacer(),
                Slider(
                  activeColor: Colors.brown,
                  value: bobaValue,
                  label: sweetValue.toString(),
                  divisions: 4,
                  onChanged: (value) => customizeBoba(value),
                ),
              ],
            ),

            //botton to cart
            MaterialButton(
              color: Colors.brown,
              onPressed: () {
                addToCart();
              },
              child: Text('add to cart', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
