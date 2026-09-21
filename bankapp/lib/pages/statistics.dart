import 'package:bankapp/colors/colors.dart';
import 'package:bankapp/tiles/transactiontile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final PageController _monthController = PageController(viewportFraction: 0.3);
  int _currentMonthIndex = 3;

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

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
            children: [
              // Header
              Container(
                color: ColorConstants.background,
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Statistics',
                        style: GoogleFonts.poppins(
                          color: ColorConstants.textcolor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.notifications,
                        color: ColorConstants.textcolor,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Current Balance
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Current Balance',
                                style: TextStyle(
                                  color: ColorConstants.silenttextcolor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$8,545.00',
                                style: TextStyle(
                                  color: ColorConstants.textcolor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Chart Placeholder
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ColorConstants.cardcolor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Chart Placeholder',
                              style: TextStyle(
                                color: ColorConstants.silenttextcolor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Month Carousel
                        SizedBox(
                          height: 50,
                          child: PageView.builder(
                            controller: _monthController,
                            itemCount: _months.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentMonthIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final isSelected = index == _currentMonthIndex;
                              return Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? ColorConstants.button
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _months[index],
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? ColorConstants.textcolor
                                              : ColorConstants.silenttextcolor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Transaction Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transaction',
                              style: TextStyle(
                                color: ColorConstants.textcolor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'See All',
                              style: TextStyle(
                                color: ColorConstants.button,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 19),

                        // Transaction Tiles
                        Column(
                          children: [
                            TransactionTile(
                              icon: Icons.apple,
                              title: "Apple Store",
                              subtitle: "Entertainment",
                              amount: "- \$5.99",
                              amountColor: ColorConstants.textcolor,
                            ),
                            const SizedBox(height: 22),
                            TransactionTile(
                              icon: Icons.music_note,
                              title: "Spotify",
                              subtitle: "Music",
                              amount: "- \$12.99",
                              amountColor: ColorConstants.textcolor,
                            ),
                            const SizedBox(height: 22),
                            TransactionTile(
                              icon: Icons.download,
                              title: "Money Transfer",
                              subtitle: "Transaction",
                              amount: "\$300",
                              amountColor: ColorConstants.button,
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
                              icon: Icons.apple,
                              title: "Apple Store",
                              subtitle: "Entertainment",
                              amount: "- \$5.99",
                              amountColor: ColorConstants.textcolor,
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
