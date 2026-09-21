import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropZone extends StatefulWidget {
  final int index;
  final String? placedLetter;
  final String expectedLetter;
  final Function(String, int) onLetterDropped;
  final bool isShaking;

  DropZone({
    Key? key,
    required this.index,
    required this.placedLetter,
    required this.expectedLetter,
    required this.onLetterDropped,
    this.isShaking = false,
  }) : super(key: key);

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(DropZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasLetter = widget.placedLetter != null;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        double offset = 0;
        if (widget.isShaking) {
          offset = sin(_shakeAnimation.value * 3.14 * 4) * 10;
        }

        return Transform.translate(
          offset: Offset(offset, 0),
          child: DragTarget<String>(
            onWillAcceptWithDetails: (details) {
              return widget.placedLetter == null;
            },
            onAcceptWithDetails: (details) {
              widget.onLetterDropped(details.data, widget.index);
            },
            builder: (context, candidateData, rejectedData) {
              bool isHovering = candidateData.isNotEmpty;

              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 70,
                height: 70,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: widget.isShaking
                      ? Colors.red.withAlpha(200)
                      : hasLetter
                      ? Color(0xFF4CAF50)
                      : (isHovering
                            ? Colors.purple.withAlpha(150)
                            : Colors.white.withAlpha(40)),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: widget.isShaking
                        ? Colors.red
                        : isHovering
                        ? Colors.yellow
                        : Colors.white,
                    width: isHovering ? 4 : 3,
                  ),
                  boxShadow: widget.isShaking
                      ? [
                          BoxShadow(
                            color: Colors.red.withAlpha(150),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ]
                      : hasLetter
                      ? [
                          BoxShadow(
                            color: Colors.green.withAlpha(100),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: hasLetter
                      ? Text(
                          widget.placedLetter!,
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.white.withAlpha(80),
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
