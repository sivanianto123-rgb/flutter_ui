import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watch_app/styles/colors/colors.dart';

class DescriptionScreen extends StatelessWidget {
  final String imagePath;
  final String name;
  final String price;
  final List<String>? variantImages;

  DescriptionScreen({
    super.key,
    required this.imagePath,
    required this.name,
    required this.price,
    this.variantImages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppColors.verticalGradient),
          ),
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          Icon(Icons.favorite_border, color: Colors.white),
                        ],
                      ),

                      SizedBox(height: 8),

                      Text(
                        price,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFF8A796B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'DIAMETER',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.primaytextColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '41 mm',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFF8A796B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'THICKNESS',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.primaytextColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '8.96 mm',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFF8A796B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'MOVEMENT',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.primaytextColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'winding',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      Text(
                        'An elegant interpretation of the perpetual calendar, this 18K pink gold watch houses an ultra-slim automatic movement. The moon phase features a star-studded sky and two gold moons.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaytextColor,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 30,
            right: 24,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white38,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_shopping_cart, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
