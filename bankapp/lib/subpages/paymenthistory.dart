import 'package:bankapp/tiles/payment_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';

import '../common_widgets/custom_widgets.dart';
import '../subpages/search.dart';

class Paymenthistory extends StatelessWidget {
  const Paymenthistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    alignment: Alignment.centerLeft,
                    child: CustomBackButton(),
                  ),

                  Center(
                    child: Text(
                      'Transaction History',
                      style: GoogleFonts.poppins(
                        color: ColorConstants.textcolor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Search(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: ColorConstants.textcolor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 29),

                    Text(
                      'Today',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 29),

                    PaymentHistoryTileList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
