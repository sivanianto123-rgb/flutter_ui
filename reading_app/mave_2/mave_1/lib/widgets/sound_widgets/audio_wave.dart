import 'dart:math';
import 'package:flutter/material.dart';

class AudioWave extends StatefulWidget {
  final bool isListening;
  final bool isSuccess;

  AudioWave({Key? key, required this.isListening, required this.isSuccess})
    : super(key: key);

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final Random _rand = Random();
  List<double> _heights = [];

  @override
  void initState() {
    super.initState();
    _heights = List.generate(25, (_) => 0.3);

    _ctrl =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600))
          ..addListener(() {
            if (widget.isListening && mounted) {
              setState(() {
                for (int i = 0; i < _heights.length; i++) {
                  _heights[i] = 0.25 + _rand.nextDouble() * 0.75;
                }
              });
            }
          });

    if (widget.isListening) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(AudioWave old) {
    super.didUpdateWidget(old);
    if (widget.isListening && !old.isListening) {
      _ctrl.repeat();
    } else if (!widget.isListening && old.isListening) {
      _ctrl.stop();
      setState(() {
        for (int i = 0; i < _heights.length; i++) {
          _heights[i] = 0.3;
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color barColor = widget.isSuccess ? Colors.green : Colors.red;

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_heights.length, (i) {
          return Container(
            width: 6,
            height: _heights[i] * 40,
            margin: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
