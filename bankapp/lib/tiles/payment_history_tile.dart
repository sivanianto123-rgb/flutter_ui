import 'package:flutter/material.dart';
import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/tiles/transactiontile.dart';

class PaymentHistoryTileList extends StatelessWidget {
  // ignore: use_super_parameters
  PaymentHistoryTileList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        itemCount:
            transactions.length, 
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < transactions.length - 1 ? 22 : 0,
            ),
            child: TransactionTile(
              title: transaction['title'],
              subtitle: transaction['subtitle'],
              amount: transaction['amount'],
              icon: transaction['icon'],
              amountColor: transaction['amountColor'],
            ),
          );
        },
      ),
    );
  }

  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'Apple Store',
      'subtitle': 'Entertainment',
      'amount': '- \$5.99',
      'icon': Icons.apple,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Spotify',
      'subtitle': 'Music',
      'amount': '- \$12.99',
      'icon': Icons.music_note,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Money Transfer',
      'subtitle': 'Transaction',
      'amount': '\$300',
      'icon': Icons.download,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Grocery',
      'subtitle': 'Shopping',
      'amount': '- \$88',
      'icon': Icons.shopping_cart,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Apple Store',
      'subtitle': 'Entertainment',
      'amount': '- \$5.99',
      'icon': Icons.tv,
      'amountColor': ColorConstants.button,
    },
    {
      'title': 'Spotify',
      'subtitle': 'Music',
      'amount': '- \$12.99',
      'icon': Icons.music_note,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Money Transfer',
      'subtitle': 'Transaction',
      'amount': '\$300',
      'icon': Icons.download,
      'amountColor': ColorConstants.button,
    },
    {
      'title': 'Spotify',
      'subtitle': 'Music',
      'amount': '- \$12.99',
      'icon': Icons.music_note,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Grocery',
      'subtitle': 'Shopping',
      'amount': '- \$88',
      'icon': Icons.shopping_cart,
      'amountColor': ColorConstants.textcolor,
    },
  ];
}
