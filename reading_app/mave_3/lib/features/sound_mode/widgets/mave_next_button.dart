import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MaveNextButton extends StatelessWidget {
  const MaveNextButton({super.key, required this.onTap, this.label = 'Next'});

  final VoidCallback onTap;
  final String       label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)],
          ),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color:      const Color(0xFFFF6B6B).withOpacity(0.5),
              blurRadius: 20,
              offset:     const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.w800,
                color:      Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end:   const Offset(1.04, 1.04),
          duration: 700.ms,
          curve: Curves.easeInOut,
        );
  }
}
