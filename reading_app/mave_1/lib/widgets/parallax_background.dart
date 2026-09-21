import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/constants/app_colors.dart';

// ---------------------------------------------------------------------------
// 3-layer parallax background.
// On iOS/Android: uses accelerometer.
// On macOS/Windows/Linux/web: uses MouseRegion hover.
// ---------------------------------------------------------------------------

class ParallaxBackground extends StatefulWidget {
  final Widget child;
  const ParallaxBackground({super.key, required this.child});

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  Offset _offset = Offset.zero;
  StreamSubscription? _accelSub;

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get _useMouse =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  @override
  void initState() {
    super.initState();
    if (_isMobile) {
      _accelSub = accelerometerEventStream().listen((event) {
        if (!mounted) return;
        setState(() {
          _offset = Offset(
            (-event.x / 10).clamp(-1.0, 1.0),
            (event.y / 10).clamp(-1.0, 1.0),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  void _onHover(PointerEvent event, BoxConstraints constraints) {
    final dx = (event.localPosition.dx / constraints.maxWidth - 0.5) * 2;
    final dy = (event.localPosition.dy / constraints.maxHeight - 0.5) * 2;
    setState(() => _offset = Offset(dx, dy));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bg = Stack(
          children: [
            // Layer 0 – deep background (slowest)
            _ParallaxLayer(
              offset: _offset,
              factor: 8,
              child: _BackgroundLayer0(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            ),
            // Layer 1 – mid (medium)
            _ParallaxLayer(
              offset: _offset,
              factor: 18,
              child: _BackgroundLayer1(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            ),
            // Layer 2 – foreground (fastest)
            _ParallaxLayer(
              offset: _offset,
              factor: 30,
              child: _BackgroundLayer2(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            ),
            // Content
            widget.child,
          ],
        );

        if (_useMouse) {
          return MouseRegion(
            onHover: (e) => _onHover(e, constraints),
            child: bg,
          );
        }
        return bg;
      },
    );
  }
}

class _ParallaxLayer extends StatelessWidget {
  final Offset offset;
  final double factor;
  final Widget child;
  const _ParallaxLayer({
    required this.offset,
    required this.factor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(offset.dx * factor, offset.dy * factor),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Background layers – solid gradient + floating shapes
// ---------------------------------------------------------------------------

class _BackgroundLayer0 extends StatelessWidget {
  final double width;
  final double height;
  const _BackgroundLayer0({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width + 80,
      height: height + 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgDeep, AppColors.bgMid],
        ),
      ),
    );
  }
}

class _BackgroundLayer1 extends StatelessWidget {
  final double width;
  final double height;
  const _BackgroundLayer1({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 120,
      height: height + 120,
      child: CustomPaint(painter: _StarsPainter()),
    );
  }
}

class _BackgroundLayer2 extends StatelessWidget {
  final double width;
  final double height;
  const _BackgroundLayer2({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 160,
      height: height + 160,
      child: CustomPaint(painter: _CloudsPainter()),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.25);
    const positions = [
      Offset(0.1, 0.12),
      Offset(0.3, 0.05),
      Offset(0.55, 0.18),
      Offset(0.75, 0.08),
      Offset(0.9, 0.22),
      Offset(0.2, 0.35),
      Offset(0.65, 0.4),
      Offset(0.85, 0.55),
      Offset(0.05, 0.7),
      Offset(0.45, 0.75),
    ];
    for (final p in positions) {
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    void cloud(double x, double y, double r) {
      canvas.drawCircle(Offset(x, y), r, paint);
      canvas.drawCircle(Offset(x + r * 0.7, y), r * 0.75, paint);
      canvas.drawCircle(Offset(x - r * 0.6, y + r * 0.2), r * 0.6, paint);
    }

    cloud(size.width * 0.15, size.height * 0.15, 60);
    cloud(size.width * 0.7, size.height * 0.1, 80);
    cloud(size.width * 0.5, size.height * 0.8, 70);
    cloud(size.width * 0.88, size.height * 0.65, 55);
  }

  @override
  bool shouldRepaint(_) => false;
}
