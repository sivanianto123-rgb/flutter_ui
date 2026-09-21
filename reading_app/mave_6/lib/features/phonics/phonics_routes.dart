import 'package:flutter/material.dart';

Route<T> buildPhonicsSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (_, animation, secondary, child) {
      final inAnim = Tween<Offset>(
        begin: const Offset(0.18, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

      final outAnim = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.06, 0),
      ).chain(CurveTween(curve: Curves.easeInOut)).animate(secondary);

      return SlideTransition(
        position: outAnim,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(position: inAnim, child: child),
        ),
      );
    },
  );
}
