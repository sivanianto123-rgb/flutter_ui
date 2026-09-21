import 'package:flutter/material.dart';
import 'package:ecommerce_app/styles/fonts.dart';

class DetailScreen extends StatelessWidget {
  final String image;
  final String title;
  final String rating;

  const DetailScreen({
    super.key,
    required this.image,
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: AssetImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -25,
                      right: 20,
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppFonts.getAppFont(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Show map',
                      style: AppFonts.getAppFont(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF196EEE),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFF8D675), size: 20),
                    SizedBox(width: 4),
                    Text(rating, style: AppFonts.w400b14),
                    Text(' (355 Reviews)', style: AppFonts.w400g13),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Aspen is as close as one can get to a storybook alpine town in America. The choose-your-own-adventure possibilities—skiing, hiking, dining shopping and ....',
                  style: AppFonts.w400g13,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Read more',
                      style: AppFonts.getAppFont(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF196EEE),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF196EEE)),
                  ],
                ),
                SizedBox(height: 24),
                Text('Facilities', style: AppFonts.w600b18),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.wifi, color: Colors.grey[600], size: 28),
                          SizedBox(height: 8),
                          Text('1 Heater', style: AppFonts.w400g10),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Colors.grey[600],
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text('Dinner', style: AppFonts.w400g10),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bathtub_outlined,
                            color: Colors.grey[600],
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text('1 Tub', style: AppFonts.w400g10),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pool, color: Colors.grey[600], size: 28),
                          SizedBox(height: 8),
                          Text('Pool', style: AppFonts.w400g10),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price', style: AppFonts.w400g13),
                        Text(
                          '\$199',
                          style: AppFonts.getAppFont(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF196EEE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Book Now',
                              style: AppFonts.getAppFont(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
