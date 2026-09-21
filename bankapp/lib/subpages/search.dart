import 'package:bankapp/tiles/transactiontile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankapp/colors/colors.dart';

import '../common_widgets/custom_widgets.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredTransactions = [];

  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Apple Store',
      'subtitle': 'Entertainment',
      'amount': '- \$5,99',
      'icon': Icons.apple,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Spotify',
      'subtitle': 'Music',
      'amount': '- \$12,99',
      'icon': Icons.music_note,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Money Transfer',
      'subtitle': 'Transaction',
      'amount': '\$300',
      'icon': Icons.arrow_downward,
      'amountColor': ColorConstants.button,
    },
    {
      'title': 'Grocery',
      'subtitle': 'Shopping',
      'amount': '- \$ 88',
      'icon': Icons.shopping_cart,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Netflix',
      'subtitle': 'Entertainment',
      'amount': '- \$5,99',
      'icon': Icons.tv,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Money Transfer',
      'subtitle': 'Transaction',
      'amount': '\$300',
      'icon': Icons.arrow_downward,
      'amountColor': ColorConstants.button,
    },
    {
      'title': 'Apple Store',
      'subtitle': 'Entertainment',
      'amount': '- \$5,99',
      'icon': Icons.apple,
      'amountColor': ColorConstants.textcolor,
    },
    {
      'title': 'Spotify',
      'subtitle': 'Music',
      'amount': '- \$12,99',
      'icon': Icons.music_note,
      'amountColor': ColorConstants.textcolor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = _allTransactions;
  }

  void _filterTransactions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTransactions = _allTransactions;
      } else {
        _filteredTransactions =
            _allTransactions.where((transaction) {
              return transaction['title'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  transaction['subtitle'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

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
                      'Search',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.textcolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: ColorConstants.cardcolor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.search,
                        color: ColorConstants.silenttextcolor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterTransactions,
                        style: GoogleFonts.poppins(
                          color: ColorConstants.textcolor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: GoogleFonts.poppins(
                            color: ColorConstants.silenttextcolor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child:
                  _filteredTransactions.isEmpty
                      ? Center(
                        child: Text(
                          'No transactions found',
                          style: GoogleFonts.poppins(
                            color: ColorConstants.textcolor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 22.0),
                            child: TransactionTile(
                              title: transaction['title'],
                              subtitle: transaction['subtitle'],
                              amount: transaction['amount'],
                              icon: transaction['icon'],
                              amountColor:
                                  transaction['amount'].toString().contains('-')
                                      ? ColorConstants.textcolor
                                      : ColorConstants.button,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
