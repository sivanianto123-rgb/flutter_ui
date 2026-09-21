import 'package:bankapp/tiles/card_tile.dart';
import 'package:bankapp/tiles/transactiontile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';

class MyCardPage extends StatefulWidget {
  const MyCardPage({super.key});

  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  double _sliderValue = 4600;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorConstants.background,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: ColorConstants.background,
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "My Cards",
                        style: GoogleFonts.poppins(
                          color: ColorConstants.textcolor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CardTile(
                  cardHolder: 'AR Jonson',
                  cardNumber: '4562   1122   4595   7852',
                  expiryDate: '24/2000',
                  cvv: '6986',
                ),
              ),

              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TransactionTile(
                      title: "Apple Store",
                      subtitle: "Entertainment",
                      amount: "- \$5.99",
                      icon: Icons.apple,
                      amountColor: ColorConstants.textcolor,
                    ),
                    SizedBox(height: 20),
                    TransactionTile(
                      title: "Spotify",
                      subtitle: "Music",
                      amount: "- \$12.99",
                      icon: Icons.music_note,
                      amountColor: ColorConstants.textcolor,
                    ),
                    SizedBox(height: 20),
                    TransactionTile(
                      title: "Grocery",
                      subtitle: "Shopping",
                      amount: "- \$88",
                      icon: Icons.shopping_cart,
                      amountColor: ColorConstants.textcolor,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSpendingLimitSlider(),
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingLimitSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Monthly spending limit",
          style: GoogleFonts.poppins(
            color: ColorConstants.textcolor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E2D),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Amount: \$${_sliderValue.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  color: ColorConstants.textcolor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Slider(
                value: _sliderValue,
                min: 0,
                max: 10000,
                activeColor: Colors.white,
                thumbColor: ColorConstants.button,
                inactiveColor: Colors.white24,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$0",
                    style: GoogleFonts.poppins(
                      color: ColorConstants.textcolor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "\$${_sliderValue.toStringAsFixed(0)}",
                    style: GoogleFonts.poppins(
                      color: ColorConstants.textcolor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "\$10,000",
                    style: GoogleFonts.poppins(
                      color: ColorConstants.textcolor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
