import 'package:flutter/material.dart';

import 'drink.dart';

class BubbleTeaShop extends ChangeNotifier {
  //lists drinks
  final List<Drink> _shop = [
    Drink(
      name: 'anto Milk Tea',
      price: '5.00',
      imagepath: 'assets/images/milk_tea.png',
    ),
    Drink(
      name: ' latte boba ',
      price: '8.00',
      imagepath: 'assets/images/latte_boba.png',
    ),
    Drink(
      name: ' boba splash Tea',
      price: '10.00',
      imagepath: 'assets/images/boba_splash.png',
    ),

    Drink(
      name: 'coffee boba',
      price: '5.00',
      imagepath: 'assets/images/coffee_boba.png',
    ),
  ];

  // lists cart

  final List<Drink> _userCart = [];

  //get drink for discount
  List<Drink> get shop => _shop;

  // user cart
  List<Drink> get cart => _userCart;
  // drink to cartttttttttt
  void addToCart(Drink drink) {
    _userCart.add(drink);
    notifyListeners();
  }

  void removeFromCart(Drink drink) {
    _userCart.remove(drink);
    notifyListeners();
  }
}
