import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftBoxWidget extends StatelessWidget {
  const GiftBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            children: [
              // Box body
              Positioned(
                bottom: 0,
                left: 4,
                right: 4,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B1FA2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              // Box lid
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Vertical ribbon
              Positioned(
                left: 32,
                top: 8,
                bottom: 0,
                child: Container(width: 10, color: const Color(0xFFFFD600)),
              ),
              // Horizontal ribbon
              Positioned(
                left: 0,
                right: 0,
                top: 16,
                child: Container(height: 10, color: const Color(0xFFFFD600)),
              ),
              // Bow left loop
              Positioned(
                top: 0,
                left: 18,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD600),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Bow right loop
              Positioned(
                top: 0,
                right: 18,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD600),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'CONTINUE READING\nTO UNLOCK GIFT',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 3)],
          ),
        ),
      ],
    );
  }
}
