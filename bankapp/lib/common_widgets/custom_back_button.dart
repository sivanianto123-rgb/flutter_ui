import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          color: Color(0xFF1E1E2D),
        ),
        child: Center(
          child: Icon(CupertinoIcons.back, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
