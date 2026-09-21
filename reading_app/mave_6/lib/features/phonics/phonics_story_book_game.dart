import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PhonicsStoryBookGame extends FlameGame {
  PhonicsStoryBookGame();

  _StoryBookComponent? _book;
  String? _pendingBody;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    _book = _StoryBookComponent(size: size.clone());
    add(_book!);
    if (_pendingBody != null) {
      _book!.setPageBody(_pendingBody!);
      _pendingBody = null;
    }
  }

  void setPageBody(String body) {
    if (_book == null) {
      _pendingBody = body;
      return;
    }
    _book!.setPageBody(body);
  }
}

class _StoryBookComponent extends PositionComponent {
  _StoryBookComponent({required Vector2 size}) {
    this.size = size;
    anchor = Anchor.center;
    position = size / 2;
  }

  late TextBoxComponent _body;
  double _time = 0;

  @override
  Future<void> onLoad() async {
    await _buildText();
  }

  Future<void> _buildText() async {
    _body = TextBoxComponent(
      text: '',
      position: Vector2(size.x * 0.20, size.y * 0.23),
      size: Vector2(size.x * 0.60, size.y * 0.56),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF4E342E),
          fontSize: 34,
          height: 1.30,
          fontWeight: FontWeight.w800,
          fontFamilyFallback: ['Georgia', 'Times New Roman', 'Verdana'],
        ),
      ),
    );
    add(_body);
  }

  void setPageBody(String body) {
    _body.text = body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    // Very subtle/slow breathing so text stays readable for kids.
    final breathe = 1 + (0.012 * (1 + math.sin((_time / 4.4) * math.pi * 2)) / 2);
    scale = Vector2.all(breathe);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final coverRect = Rect.fromLTWH(size.x * 0.08, size.y * 0.12, size.x * 0.84, size.y * 0.74);
    final leftPageRect = Rect.fromLTWH(size.x * 0.12, size.y * 0.16, size.x * 0.38, size.y * 0.64);
    final rightPageRect = Rect.fromLTWH(size.x * 0.50, size.y * 0.16, size.x * 0.38, size.y * 0.64);

    // Outer purple cover.
    canvas.drawRRect(
      RRect.fromRectAndRadius(coverRect, const Radius.circular(18)),
      Paint()..color = const Color(0xFF5A53B2),
    );

    // Page stack shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.11, size.y * 0.18, size.x * 0.78, size.y * 0.65),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFFF2EAD2),
    );

    // Left + right page surfaces.
    final pagePaint = Paint()..color = const Color(0xFFF4ECD1);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        leftPageRect,
        topLeft: const Radius.circular(24),
        bottomLeft: const Radius.circular(20),
      ),
      pagePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rightPageRect,
        topRight: const Radius.circular(24),
        bottomRight: const Radius.circular(20),
      ),
      pagePaint,
    );

    // Center fold / spine seam.
    canvas.drawLine(
      Offset(size.x * 0.50, size.y * 0.16),
      Offset(size.x * 0.50, size.y * 0.80),
      Paint()
        ..color = const Color(0xC0B6AD8C)
        ..strokeWidth = 2,
    );

    // Bottom page depth curve.
    final curve = Path()
      ..moveTo(size.x * 0.14, size.y * 0.78)
      ..quadraticBezierTo(size.x * 0.50, size.y * 0.83, size.x * 0.86, size.y * 0.78);
    canvas.drawPath(
      curve,
      Paint()
        ..color = const Color(0xAA9E957A)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }
}
