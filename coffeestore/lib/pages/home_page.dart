import 'package:coffeestore/util/coffee_tile.dart';
import 'package:coffeestore/util/coffee_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List coffeType = [
    // the lsit cof_type,isselected
    ['all', false],
    ['Cappucciono', false],
    ['Expresso', false],
    ['Americano', false],
    ['Machiato', true],
  ];
  // user tappd on coffee types
  void coffeeTypeSelected(int index) {
    setState(() {
      // loop make the selection false
      for (int i = 0; i < coffeType.length; i++) {
        coffeType[i][1] = false;
      }
      coffeType[index][1] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Icon(Icons.window),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.person),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        ],
      ),
      body: Column(
        children: [
          // find the best coffee for you
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Find the best coffee for you",
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 25),
          //search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Find your poison...',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
              ),
            ),
          ),

          SizedBox(height: 25),
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: coffeType.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    coffeeTypeSelected(index);
                  },
                  child: CoffeeType(
                    coffeType: coffeType[index][0],
                    isSelected: coffeType[index][1],
                    onTap: () {
                      coffeeTypeSelected(index);
                    },
                  ),
                );
              },
            ),
          ),

          //horizontal listview of coffee titles
          Flexible(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CoffeeTile(
                  coffeeImagepath: 'lib/images/latte.png',
                  coffeeName: 'Latte',
                  coffeePrice: '4.20',
                ),
                CoffeeTile(
                  coffeeImagepath: 'lib/images/coffee.png',
                  coffeeName: 'coffee',
                  coffeePrice: '5.20',
                ),
                CoffeeTile(
                  coffeeImagepath: 'lib/images/milk.png',
                  coffeeName: 'Milk',
                  coffeePrice: '3.20',
                ),
                CoffeeTile(
                  coffeeImagepath: 'lib/images/black_coffee.png',
                  coffeeName: 'Black Coffee',
                  coffeePrice: '4.20',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
