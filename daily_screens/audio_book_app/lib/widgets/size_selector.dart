import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../styles/fonts.dart';

class SizeSelectorSection extends StatefulWidget {
  const SizeSelectorSection({super.key});

  @override
  State<SizeSelectorSection> createState() => _SizeSelectorSectionState();
}

class _SizeSelectorSectionState extends State<SizeSelectorSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Size', style: AppFonts.w600b17),
              Text('Size Guide', style: AppFonts.w400g13),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? AppColors.primaryColor
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style: AppFonts.w500b17.copyWith(
                          color: _selectedIndex == 0
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? AppColors.primaryColor
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'M',
                        style: AppFonts.w500b17.copyWith(
                          color: _selectedIndex == 1
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 2
                          ? AppColors.primaryColor
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'L',
                        style: AppFonts.w500b17.copyWith(
                          color: _selectedIndex == 2
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 3
                          ? AppColors.primaryColor
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'XL',
                        style: AppFonts.w500b17.copyWith(
                          color: _selectedIndex == 3
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 4
                          ? AppColors.primaryColor
                          : AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '2XL',
                        style: AppFonts.w500b17.copyWith(
                          color: _selectedIndex == 4
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
