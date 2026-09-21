import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../widgets/add_to_cart.dart';
import '../widgets/description.dart';
import '../widgets/product_widgets/product_header.dart';
import '../widgets/product_widgets/product_image.dart';
import '../widgets/product_widgets/product_info.dart';
import '../widgets/reviews.dart';
import '../widgets/size_selector.dart';

class ProductDetailScreen extends StatelessWidget {
  final String name;
  final String category;
  final double price;
  final String mainImage;
  final List<String> thumbnailImages;

  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.mainImage,
    required this.thumbnailImages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ProductDetailHeader(
                      onBackTap: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 20),
                    ProductImageGallery(
                      mainImage: mainImage,
                      thumbnailImages: thumbnailImages,
                    ),
                    SizedBox(height: 25),
                    ProductInfoSection(
                      name: name,
                      category: category,
                      price: price,
                    ),
                    SizedBox(height: 25),
                    SizeSelectorSection(),
                    SizedBox(height: 25),
                    DescriptionSection(),
                    SizedBox(height: 25),
                    ReviewsSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            AddToCartBar(
              totalPrice: price + 5,
              onAddToCart: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added to cart!'),
                    backgroundColor: AppColors.purple,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
