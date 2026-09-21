// Level 4 — Sound Bubble Pop (Flame game)
//
// Colorful glossy bubbles float up from the bottom of the screen, each
// labelled with a phoneme syllable.  Tapping a bubble pops it with a ring
// burst, plays the syllable via TTS, and increments the score.
// Popping [_kTarget] bubbles completes the level.

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_providers.dart';
import '../../../core/services/audio_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const int    _kTarget     = 10;    // pops needed to finish
const int    _kMaxOnScreen = 6;    // concurrent bubbles cap
const double _kSpawnLo    = 1.1;   // spawn interval range (seconds)
const double _kSpawnHi    = 2.2;

// Each entry: [outer colour, inner highlight colour]
const List<List<Color>> _kPalette = [
  [Color(0xFFFF6B6B), Color(0xFFFF9F9F)],  // coral
  [Color(0xFF6BCB77), Color(0xFF99E8A3)],  // green
  [Color(0xFF4D96FF), Color(0xFF89BCFF)],  // blue
  [Color(0xFFFFBE0B), Color(0xFFFFD76A)],  // amber
  [Color(0xFFFF9F43), Color(0xFFFFBF80)],  // orange
  [Color(0xFFB45FFC), Color(0xFFCE93FF)],  // purple
];

// ─────────────────────────────────────────────────────────────────────────────
// Flutter wrapper
// ─────────────────────────────────────────────────────────────────────────────

class Level4Screen extends ConsumerStatefulWidget {
  const Level4Screen({
    super.key,
    required this.syllable,
    required this.onFinish,
  });

  final String       syllable;
  final VoidCallback onFinish;

  @override
  ConsumerState<Level4Screen> createState() => _Level4ScreenState();
}

class _Level4ScreenState extends ConsumerState<Level4Screen> {
  late final BubblePopGame _game;

  @override
  void initState() {
    super.initState();
    _game = BubblePopGame(
      syllable:     widget.syllable,
      audioService: ref.read(audioServiceProvider),
      onComplete:   widget.onFinish,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flame game
// ─────────────────────────────────────────────────────────────────────────────

class BubblePopGame extends FlameGame {
  BubblePopGame({
    required this.syllable,
    required this.audioService,
    required this.onComplete,
  });

  final String       syllable;
  final AudioService audioService;
  final VoidCallback onComplete;

  int  _popped    = 0;
  bool _completed = false;

  late _ScoreHud  _hud;
  late List<String> _pool;

  @override
  Color backgroundColor() => const Color(0xFF4FC3F7);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pool = _buildPool(syllable);

    world.add(_SkyBackground());
    _hud = _ScoreHud(target: _kTarget);
    camera.viewport.add(_hud);
    world.add(_Spawner());
  }

  // Called by every bubble when tapped
  void onPop(String label) {
    if (_completed) return;
    _popped++;
    _hud.setScore(_popped);
    audioService.speak(label); // fire and forget
    if (_popped >= _kTarget) {
      _completed = true;
      Future.delayed(const Duration(milliseconds: 1400), onComplete);
    }
  }

  String randomSyllable() => _pool[math.Random().nextInt(_pool.length)];

  // 60 % target syllable, 40 % phonetically-close distractors
  static List<String> _buildPool(String t) {
    const near = {
      'ma': ['ba', 'pa', 'la', 'da'],
      'pa': ['ba', 'ma', 'ta', 'da'],
      'ba': ['ma', 'pa', 'da', 'la'],
      'ta': ['da', 'pa', 'ba', 'na'],
      'da': ['ta', 'ba', 'na', 'ma'],
      'na': ['ma', 'ba', 'la', 'da'],
      'la': ['ma', 'na', 'da', 'ba'],
      'sa': ['ma', 'ba', 'pa', 'la'],
      'ka': ['ma', 'ba', 'pa', 'ta'],
      'ra': ['ma', 'ba', 'la', 'da'],
    };
    final pool = [t, t, t]; // weight target higher
    pool.addAll((near[t] ?? ['ba', 'pa']).take(2));
    return pool;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sky background — gradient + drifting clouds + grass strip
// ─────────────────────────────────────────────────────────────────────────────

class _CloudData {
  _CloudData(this.x, this.y, this.scale, this.speed);
  double x, y;
  final double scale, speed;
}

class _SkyBackground extends PositionComponent
    with HasGameReference<BubblePopGame> {

  _SkyBackground() : super(priority: -10, anchor: Anchor.topLeft);

  final _rng = math.Random();
  final _clouds = <_CloudData>[];

  @override
  Future<void> onLoad() async {
    _resize(game.size);
    for (int i = 0; i < 6; i++) {
      _clouds.add(_CloudData(
        _rng.nextDouble() * size.x,
        30 + _rng.nextDouble() * size.y * 0.32,
        0.4 + _rng.nextDouble() * 1.0,
        10 + _rng.nextDouble() * 20,
      ));
    }
  }

  @override
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    _resize(s);
  }

  void _resize(Vector2 s) { size = s; position = Vector2.zero(); }

  @override
  void update(double dt) {
    for (final c in _clouds) {
      c.x += c.speed * dt;
      if (c.x > size.x + 200) c.x = -200;
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Sky gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [Color(0xFF0288D1), Color(0xFF29B6F6), Color(0xFF81D4FA)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    for (final c in _clouds) _drawCloud(canvas, c);

    // Grass
    canvas.drawRect(
      Rect.fromLTWH(0, h - 70, w, 70),
      Paint()..color = const Color(0xFF43A047),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h - 70, w, 14),
      Paint()..color = const Color(0xFF66BB6A),
    );
  }

  void _drawCloud(Canvas canvas, _CloudData c) {
    final p = Paint()..color = Colors.white.withOpacity(0.86);
    final s = c.scale * 52;
    canvas.drawCircle(Offset(c.x,             c.y),          s * 0.58, p);
    canvas.drawCircle(Offset(c.x + s * 0.82,  c.y),          s * 0.48, p);
    canvas.drawCircle(Offset(c.x - s * 0.72,  c.y),          s * 0.44, p);
    canvas.drawCircle(Offset(c.x + s * 0.32,  c.y + s * 0.30), s * 0.66, p);
    canvas.drawCircle(Offset(c.x - s * 0.18,  c.y + s * 0.28), s * 0.53, p);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score HUD — lives in camera.viewport (screen-fixed)
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreHud extends Component {
  _ScoreHud({required this.target});

  final int target;
  int _score = 0;

  void setScore(int n) => _score = n;

  static const _pad    = 16.0;
  static const _height = 46.0;
  static const _width  = 128.0;

  @override
  void render(Canvas canvas) {
    final rect  = const Rect.fromLTWH(_pad, _pad, _width, _height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(23));

    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()
        ..color      = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Pill
    canvas.drawRRect(rrect, Paint()..color = Colors.white.withOpacity(0.90));

    // Text
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        children: [
          const TextSpan(text: '⭐  ', style: TextStyle(fontSize: 19)),
          TextSpan(
            text: '$_score / $target',
            style: const TextStyle(
              fontSize:   19,
              fontWeight: FontWeight.w900,
              color:      Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    )..layout();

    tp.paint(
      canvas,
      Offset(
        _pad + (_width - tp.width) / 2,
        _pad + (_height - tp.height) / 2,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble spawner
// ─────────────────────────────────────────────────────────────────────────────

class _Spawner extends Component with HasGameReference<BubblePopGame> {
  final _rng = math.Random();

  double _timer    = 0;
  double _interval = 0.4;   // first bubble appears quickly
  int    _alive    = 0;
  int    _total    = 0;

  @override
  void update(double dt) {
    if (game._completed) return;
    _timer += dt;
    if (_timer >= _interval && _alive < _kMaxOnScreen) {
      _timer    = 0;
      _interval = _kSpawnLo + _rng.nextDouble() * (_kSpawnHi - _kSpawnLo);
      _spawnOne();
    }
  }

  void _spawnOne() {
    _alive++;
    _total++;

    final w       = game.size.x;
    final h       = game.size.y;
    final radius  = 28.0 + _rng.nextDouble() * 24;
    final x       = radius + _rng.nextDouble() * (w - 2 * radius);
    final speed   = 55.0  + _rng.nextDouble() * 60;
    final palette = _total % _kPalette.length;

    game.world.add(_Bubble(
      syllable:  game.randomSyllable(),
      radius:    radius,
      speed:     speed,
      startPos:  Vector2(x, h + radius + 10),
      palette:   palette,
      onPopped:  (s) { _alive--; game.onPop(s); },
      onEscaped: ()  { _alive--; },
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble component
// ─────────────────────────────────────────────────────────────────────────────

class _Bubble extends PositionComponent
    with TapCallbacks, HasGameReference<BubblePopGame> {

  _Bubble({
    required this.syllable,
    required this.radius,
    required this.speed,
    required Vector2 startPos,
    required this.palette,
    required this.onPopped,
    required this.onEscaped,
  }) : super(
          position: startPos,
          size:     Vector2.all(radius * 2),
          anchor:   Anchor.center,
        );

  final String   syllable;
  final double   radius;
  final double   speed;
  final int      palette;
  final void Function(String) onPopped;
  final VoidCallback          onEscaped;

  final _rng = math.Random();

  bool   _popping  = false;
  double _popT     = 0;
  double _phase    = 0;         // wobble accumulator

  late final double _wobbleHz  = 0.6 + _rng.nextDouble() * 0.6;
  late final double _wobbleAmp = 5   + _rng.nextDouble() * 10;

  @override
  Future<void> onLoad() async {
    _phase = _rng.nextDouble() * math.pi * 2;
  }

  @override
  bool containsLocalPoint(Vector2 p) {
    final c = Vector2(radius, radius);
    return (p - c).length <= radius;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_popping) return;
    _popping = true;
    event.handled = true;
    onPopped(syllable);
    game.world.add(_PopBurst(
      position: position.clone(),
      colors:   _kPalette[palette],
    ));
  }

  @override
  void update(double dt) {
    if (_popping) {
      _popT += dt;
      if (_popT >= 0.32) removeFromParent();
      return;
    }

    _phase     += dt;
    position.y -= speed * dt;
    position.x += math.sin(_phase * _wobbleHz * math.pi * 2) * _wobbleAmp * dt;

    if (position.y < -(radius * 2 + 20)) {
      onEscaped();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    double alpha    = 1.0;
    double popScale = 1.0;

    if (_popping) {
      final t = (_popT / 0.32).clamp(0.0, 1.0);
      popScale = 1 + t * 0.55;
      alpha    = 1 - t;
    }

    final cx     = radius;
    final cy     = radius;
    final colors = _kPalette[palette];

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(popScale);
    canvas.translate(-cx, -cy);

    // ── Outer glow ────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      radius * 1.18,
      Paint()
        ..color      = colors[0].withOpacity(0.26 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // ── Body: radial gradient ─────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.30, -0.40),
          radius: 1.05,
          colors: [
            colors[1].withOpacity(0.78 * alpha),
            colors[0].withOpacity(0.92 * alpha),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius)),
    );

    // ── Glass highlight (top-left) ────────────────────────────────────────
    final hlCenter = Offset(cx - radius * 0.30, cy - radius * 0.32);
    canvas.drawCircle(
      hlCenter,
      radius * 0.46,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.75 * alpha),
            Colors.white.withOpacity(0.00),
          ],
        ).createShader(
            Rect.fromCircle(center: hlCenter, radius: radius * 0.46)),
    );

    // ── Small secondary shine (bottom-right) ─────────────────────────────
    canvas.drawCircle(
      Offset(cx + radius * 0.35, cy + radius * 0.35),
      radius * 0.18,
      Paint()..color = Colors.white.withOpacity(0.30 * alpha),
    );

    // ── Rim ───────────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      radius - 1.5,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color       = Colors.white.withOpacity(0.40 * alpha),
    );

    // ── Syllable label ────────────────────────────────────────────────────
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: syllable,
        style: TextStyle(
          fontSize:   radius * 0.72,
          fontWeight: FontWeight.w900,
          color:      Colors.white.withOpacity(alpha),
          shadows: [
            Shadow(
              color:      Colors.black26.withOpacity(0.30 * alpha),
              blurRadius: 6,
              offset:     const Offset(0, 1.5),
            ),
          ],
        ),
      ),
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    canvas.restore();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pop burst effect  (expanding rings + flying dots + sparkles)
// ─────────────────────────────────────────────────────────────────────────────

class _Dot {
  _Dot(this.angle, double speed) : vx = math.cos(angle) * speed, vy = math.sin(angle) * speed, x = 0, y = 0;
  final double angle;
  double x, y, vx, vy;
}

class _PopBurst extends PositionComponent {
  _PopBurst({required Vector2 position, required this.colors})
      : super(position: position, anchor: Anchor.center, priority: 10);

  final List<Color> colors;
  final _rng = math.Random();

  double _t = 0;
  static const double _dur = 0.50;

  late final List<_Dot> _dots = List.generate(12, (i) {
    final angle = (i / 12) * math.pi * 2 + _rng.nextDouble() * 0.5;
    final speed = 80.0 + _rng.nextDouble() * 80;
    return _Dot(angle, speed);
  });

  @override
  void update(double dt) {
    _t += dt;
    if (_t >= _dur) { removeFromParent(); return; }
    for (final d in _dots) {
      d.x  += d.vx * dt;
      d.y  += d.vy * dt;
      d.vx *= (1 - 3.5 * dt);   // decelerate
      d.vy *= (1 - 3.5 * dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final p = (_t / _dur).clamp(0.0, 1.0);
    final a = (1 - p);

    // Outer ring
    canvas.drawCircle(
      Offset.zero, 52 * p,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 3.5 * (1 - p)
        ..color       = colors[0].withOpacity(a * 0.85),
    );

    // Inner ring
    canvas.drawCircle(
      Offset.zero, 28 * p,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1 - p)
        ..color       = Colors.white.withOpacity(a * 0.70),
    );

    // Dots
    for (final d in _dots) {
      canvas.drawCircle(
        Offset(d.x, d.y),
        (5.5 - 3.5 * p).clamp(1.0, 6.0),
        Paint()..color = colors[1].withOpacity(a),
      );
    }

    // Radial sparkles around centre
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2 + _t * 7;
      final dist  = 20 * p;
      canvas.drawCircle(
        Offset(math.cos(angle) * dist, math.sin(angle) * dist),
        (4 - 3 * p).clamp(0.5, 4.5),
        Paint()..color = Colors.white.withOpacity(a * 0.90),
      );
    }
  }
}
