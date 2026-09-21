import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/tiles/transactiontile.dart';
import 'package:bankapp/tiles/card_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(
                        'lib/assets/images/profile.png',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.silenttextcolor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tanya Myroniuk',
                            style: GoogleFonts.poppins(
                              color: ColorConstants.textcolor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.search, color: Colors.white),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),

                        const CardTile(
                          cardHolder: 'AR Jonson',
                          cardNumber: '4562   1122   4595   7852',
                          expiryDate: '24/2000',
                          cvv: '6986',
                        ),

                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _ActionItem(icon: Icons.send, label: 'Send'),
                            _ActionItem(
                              icon: Icons.call_received,
                              label: 'Receive',
                            ),
                            _ActionItem(
                              icon: Icons.monetization_on,
                              label: 'Loan',
                            ),
                            _ActionItem(
                              icon: Icons.add_circle_outline,
                              label: 'Topup',
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transaction',
                              style: GoogleFonts.poppins(
                                color: ColorConstants.textcolor,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'See All',
                              style: GoogleFonts.poppins(
                                color: ColorConstants.button,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 19),

                        Column(
                          children: [
                            TransactionTile(
                              title: 'Apple Store',
                              subtitle: 'Entertainment',
                              amount: '- \$5.99',
                              icon: Icons.shopping_bag,
                              amountColor: ColorConstants.textcolor,
                            ),
                            const SizedBox(height: 22),
                            TransactionTile(
                              title: 'Spotify',
                              subtitle: 'Music',
                              amount: '- \$12.99',
                              icon: Icons.music_note,
                              amountColor: ColorConstants.textcolor,
                            ),
                            const SizedBox(height: 22),
                            TransactionTile(
                              title: 'Money Transfer',
                              subtitle: 'Transaction',
                              amount: '+ \$300.00',
                              icon: Icons.compare_arrows,
                              amountColor: ColorConstants.button,
                            ),
                            const SizedBox(height: 22),
                            TransactionTile(
                              title: 'Grocery',
                              subtitle: 'Daily Needs',
                              amount: '- \$88.00',
                              icon: Icons.local_grocery_store,
                              amountColor: ColorConstants.textcolor,
                            ),
                            const SizedBox(height: 22),
                            TransactionTile(
                              title: 'Money Transfer',
                              subtitle: 'Transaction',
                              amount: '+ \$300.00',
                              icon: Icons.compare_arrows,
                              amountColor: ColorConstants.button,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionItem({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: ColorConstants.icon,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: ColorConstants.textcolor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
