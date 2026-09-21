import 'package:flutter/material.dart';
import 'package:watch_app/styles/fonts/fonts.dart';
import 'package:watch_app/widgets/top_sell/top_sell_list.dart';

class TopSell extends StatelessWidget {
  const TopSell({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Top Sell', style: AppFonts.w500b21)],
        ),
        SizedBox(height: 12),
        TopSellList(),
      ],
    );
  }
}
