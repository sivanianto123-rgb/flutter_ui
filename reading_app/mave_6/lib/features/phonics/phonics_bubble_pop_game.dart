import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PhonicsBubblePopGame extends FlameGame {
  PhonicsBubblePopGame({
    required this.targetSound,
    required this.onProgress,
    required this.onCompleted,
    this.onCorrectTap,
    this.onWrongTap,
  });

  final String targetSound;
  final ValueChanged<int> onProgress;
  final VoidCallback onCompleted;
  final VoidCallback? onCorrectTap;
  final VoidCallback? onWrongTap;

  final _rng = math.Random();
  int totalTargets = 0;
  int poppedTargets = 0;
  bool _showered = false;
  double _showerTimer = 0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await _spawnBubbles();
  }

  Future<void> _spawnBubbles() async {
    const all = ['ma', 'ba', 'da', 'la', 'sa', 'pa', 'ta', 'na'];
    final distractors = all.where((s) => s != targetSound).toList()
      ..shuffle(_rng);
    final labels = <String>[
      targetSound,
      targetSound,
      targetSound,
      targetSound,
      ...distractors.take(7),
    ];

    final radii = List<double>.generate(
      labels.length,
      (_) => 34 + _rng.nextDouble() * 12,
    );
    final positions = _nonOverlappingPositions(
      area: size,
      radii: radii,
      topPadding: 24,
      bottomPadding: 24,
      sidePadding: 24,
      gap: 10,
    );

    for (int i = 0; i < labels.length; i++) {
      final bubble = _BubbleComponent(
        label: labels[i],
        target: labels[i] == targetSound,
        center: positions[i],
        radius: radii[i],
        phase: _rng.nextDouble() * math.pi * 2,
        onCorrectPop: (position) => _handleCorrectPop(position),
        onWrongPop: () => onWrongTap?.call(),
      );
      if (bubble.target) totalTargets += 1;
      await add(bubble);
    }
  }

  List<Vector2> _nonOverlappingPositions({
    required Vector2 area,
    required List<double> radii,
    required double topPadding,
    required double bottomPadding,
    required double sidePadding,
    required double gap,
  }) {
    final points = <Vector2>[];
    for (int i = 0; i < radii.length; i++) {
      final r = radii[i];
      Vector2 p = Vector2(
        sidePadding +
            r +
            _rng.nextDouble() * (area.x - sidePadding * 2 - (r * 2)),
        topPadding +
            r +
            _rng.nextDouble() * (area.y - topPadding - bottomPadding - (r * 2)),
      );
      int guard = 0;
      bool collides() {
        for (int j = 0; j < points.length; j++) {
          final minAllowed = radii[j] + r + gap;
          if (points[j].distanceTo(p) < minAllowed) return true;
        }
        return false;
      }

      while (collides() && guard < 600) {
        p = Vector2(
          sidePadding +
              r +
              _rng.nextDouble() * (area.x - sidePadding * 2 - (r * 2)),
          topPadding +
              r +
              _rng.nextDouble() *
                  (area.y - topPadding - bottomPadding - (r * 2)),
        );
        guard++;
      }
      points.add(p);
    }
    return points;
  }

  void _handleCorrectPop(Vector2 position) {
    poppedTargets += 1;
    onProgress(poppedTargets);
    onCorrectTap?.call();
    _spawnBurst(position, count: 18);

    if (!_showered && poppedTargets >= totalTargets && totalTargets > 0) {
      _showered = true;
      _spawnShower();
      onCompleted();
    }
  }

  void _spawnBurst(Vector2 position, {required int count}) {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 90 + _rng.nextDouble() * 130;
      add(
        _ConfettiParticle(
          position: position.clone(),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          color: Colors.primaries[i % Colors.primaries.length],
        ),
      );
    }
  }

  void _spawnShower() {
    for (int i = 0; i < 160; i++) {
      final x = _rng.nextDouble() * size.x;
      final y = -10 - _rng.nextDouble() * 140;
      final vx = (_rng.nextDouble() - 0.5) * 80;
      final vy = 100 + _rng.nextDouble() * 180;
      add(
        _ConfettiParticle(
          position: Vector2(x, y),
          velocity: Vector2(vx, vy),
          color: Colors.primaries[_rng.nextInt(Colors.primaries.length)],
          life: 2.8 + _rng.nextDouble() * 1.6,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_showered) return;
    _showerTimer += dt;
    if (_showerTimer < 0.16) return;
    _showerTimer = 0;
    for (int i = 0; i < 14; i++) {
      final x = _rng.nextDouble() * size.x;
      final y = -8 - _rng.nextDouble() * 40;
      final vx = (_rng.nextDouble() - 0.5) * 70;
      final vy = 110 + _rng.nextDouble() * 160;
      add(
        _ConfettiParticle(
          position: Vector2(x, y),
          velocity: Vector2(vx, vy),
          color: Colors.primaries[_rng.nextInt(Colors.primaries.length)],
          life: 2.3 + _rng.nextDouble() * 1.2,
        ),
      );
    }
  }
}

class _BubbleComponent extends PositionComponent with TapCallbacks {
  _BubbleComponent({
    required this.label,
    required this.target,
    required Vector2 center,
    required this.radius,
    required this.phase,
    required this.onCorrectPop,
    required this.onWrongPop,
  }) : super(
         position: center,
         anchor: Anchor.center,
         size: Vector2.all(radius * 2),
       );

  final String label;
  final bool target;
  final double radius;
  final double phase;
  final ValueChanged<Vector2> onCorrectPop;
  final VoidCallback onWrongPop;

  double _time = 0;
  bool _popping = false;
  double _popTime = 0;
  double _alpha = 1;
  late final TextComponent _text;

  @override
  Future<void> onLoad() async {
    _text = TextComponent(
      text: label.toUpperCase(),
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    add(_text);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_popping) return;
    if (!target) {
      onWrongPop();
      return;
    }
    _popping = true;
    onCorrectPop(position.clone());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_popping) {
      _popTime += dt;
      final t = (_popTime / 0.25).clamp(0.0, 1.0);
      final s = 1 - (t * 0.7);
      scale = Vector2.all(s);
      _alpha = (1 - t).toDouble();
      if (t >= 1) {
        removeFromParent();
      }
      return;
    }

    final breathe =
        (target
                ? 1 + (math.sin((_time / 2.6) * math.pi * 2 + phase) * 0.065)
                : 1.0)
            .toDouble();
    scale = Vector2.all(breathe);
  }

  @override
  void render(Canvas canvas) {
    final base = Paint()
      ..color = (target ? const Color(0xFF4FC3F7) : const Color(0xFF64B5F6))
          .withValues(alpha: _alpha);
    final rim = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * _alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final glow = Paint()
      ..color = (target ? const Color(0xFF4FC3F7) : const Color(0xFF64B5F6))
          .withValues(alpha: 0.26 * _alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);

    canvas.drawCircle(size.toOffset() / 2, radius + 3, glow);
    canvas.drawCircle(size.toOffset() / 2, radius, base);
    canvas.drawCircle(size.toOffset() / 2, radius, rim);
    canvas.drawCircle(
      Offset(size.x * 0.35, size.y * 0.3),
      radius * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.42 * _alpha),
    );
    super.render(canvas);
  }
}

class _ConfettiParticle extends PositionComponent {
  _ConfettiParticle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    this.life = 1.6,
  }) : super(position: position, size: Vector2(6, 10), anchor: Anchor.center);

  Vector2 velocity;
  final Color color;
  double life;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= life) {
      removeFromParent();
      return;
    }
    position += velocity * dt;
    velocity = Vector2(velocity.x * 0.99, velocity.y + 180 * dt);
    angle += dt * 4;
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1 - (_age / life)).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color.withValues(alpha: alpha),
    );
  }
}
