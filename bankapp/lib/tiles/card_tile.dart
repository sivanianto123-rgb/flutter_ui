import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';

class CardTile extends StatelessWidget {
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cvv;

  const CardTile({
    super.key,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorConstants.cardcolor.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.credit_card_rounded, color: Colors.white),
              Spacer(),
              Icon(Icons.wifi, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            cardNumber,
            style: GoogleFonts.inter(
              color: ColorConstants.textcolor,
              fontSize: 24,

              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            cardHolder,
            style: GoogleFonts.inter(
              color: ColorConstants.textcolor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expiry Date',
                        style: GoogleFonts.inter(
                          color: ColorConstants.silenttextcolor,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        expiryDate,
                        style: GoogleFonts.inter(
                          color: ColorConstants.textcolor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CVV',
                        style: GoogleFonts.inter(
                          color: ColorConstants.silenttextcolor,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        cvv,
                        style: GoogleFonts.inter(
                          color: ColorConstants.textcolor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 20,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mastercard',
                    style: GoogleFonts.inter(
                      color: ColorConstants.textcolor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
