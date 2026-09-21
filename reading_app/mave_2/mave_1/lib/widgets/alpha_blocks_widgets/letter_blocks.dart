import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterBlock extends StatelessWidget {
  final String letter;
  final Color color;
  final bool isDragging;
  final double size;

  LetterBlock({
    Key? key,
    required this.letter,
    required this.color,
    this.isDragging = false,
    this.size = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.outfit(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DraggableLetterBlock extends StatelessWidget {
  final String letter;
  final String letterId;
  final Color color;
  final bool isUsed;
  final double size;

  DraggableLetterBlock({
    Key? key,
    required this.letter,
    required this.letterId,
    required this.color,
    this.isUsed = false,
    this.size = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isUsed) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withAlpha(50), width: 3),
        ),
      );
    }

    return Draggable<String>(
      data: letterId,
      feedback: Material(
        color: Colors.transparent,
        child: LetterBlock(
          letter: letter,
          color: color,
          isDragging: true,
          size: size + 10,
        ),
      ),
      childWhenDragging: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withAlpha(50), width: 3),
        ),
      ),
      child: LetterBlock(letter: letter, color: color, size: size),
    );
  }
}
