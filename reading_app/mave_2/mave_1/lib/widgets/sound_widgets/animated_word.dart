import 'dart:async';
import '../../utils/common_imports/common_imports.dart';

class AnimatedWord extends StatefulWidget {
  final List<String> syllables;
  final int currentIndex;
  final bool isAnimating;
  final VoidCallback onSyllableComplete;

  AnimatedWord({
    Key? key,
    required this.syllables,
    required this.currentIndex,
    required this.isAnimating,
    required this.onSyllableComplete,
  }) : super(key: key);

  @override
  State<AnimatedWord> createState() => _AnimatedWordState();
}

class _AnimatedWordState extends State<AnimatedWord> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimating) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(AnimatedWord oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startTimer();
    } else if (widget.isAnimating &&
        widget.currentIndex != oldWidget.currentIndex) {
      _startTimer();
    } else if (!widget.isAnimating) {
      _cancelTimer();
    }
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Timer(Duration(milliseconds: 500), () {
      if (mounted && widget.isAnimating) {
        widget.onSyllableComplete();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.syllables.length, (index) {
        bool isActive = widget.isAnimating && index == widget.currentIndex;
        bool isPast = index < widget.currentIndex;

        return Text(
          widget.syllables[index],
          style: GoogleFonts.outfit(
            fontSize: isActive ? 52 : 48,
            fontWeight: FontWeight.bold,
            color: isActive
                ? Color(0xFFE53935)
                : isPast
                ? Color(0xFF4A4A4A)
                : Color(0xFF9E9E9E),
          ),
        );
      }),
    );
  }
}
