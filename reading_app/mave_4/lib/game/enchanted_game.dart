import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color;

import 'components/background_component.dart';
import 'components/butterfly_component.dart';
import 'components/door_interactable.dart';
import 'components/ground_component.dart';
import 'components/player_component.dart';
import 'components/swing_component.dart';

// ── World ─────────────────────────────────────────────────────────────────────

/// The game world that owns all scene objects.
/// HasCollisionDetection lives here so all child components participate
/// in the same broadphase quadtree.
class EnchantedWorld extends World with HasCollisionDetection {}

// ── Game ──────────────────────────────────────────────────────────────────────

class MyEnchantedGame extends FlameGame<EnchantedWorld>
    with HasKeyboardHandlerComponents {
  // ── Logical resolution (16:9) ────────────────────────────────────────────
  static const double gameWidth = 1920.0;
  static const double gameHeight = 1080.0;

  /// Y-coordinate (top edge) of the wooden floor, estimated from the scene.
  static const double groundY = 830.0;

  // ── Phase 1 coordinate estimates (1920×1080) ─────────────────────────────
  //
  //  Floor:       top edge at y = 830
  //  Door:        x=1085  y=545   w=125  h=285   (yellow arch, blue cottage)
  //  Swing L:     pivot (255, 302)  arm 385 px   → seat centre ≈ (255, 696)
  //  Swing R:     pivot (355, 302)  arm 385 px   → seat centre ≈ (355, 696)
  //  Tree L:      Rect(0,0, 500,650)
  //  Tree R:      Rect(1100,0, 820,480)
  //  Butterflies: upper 70 % of screen, avoiding cottage zone x∈[880,1420] y>320

  @override
  Color backgroundColor() => const Color(0xFF7EC8E3);

  @override
  Future<void> onLoad() async {
    // ── Camera: fixed 1920×1080 virtual resolution ───────────────────────
    final cam = CameraComponent.withFixedResolution(
      world: world,
      width: gameWidth,
      height: gameHeight,
    )
      ..viewfinder.anchor = Anchor.topLeft  // world (0,0) = screen top-left
      ..viewfinder.position = Vector2.zero();

    await add(cam);

    // ── Scene objects (z-order = priority) ──────────────────────────────
    await world.addAll([
      BackgroundComponent(),                              // priority 0
      GroundComponent(),                                  // priority 1
      DoorInteractable(),                                 // priority 2
      SwingComponent(pivot: Vector2(255, 302), armLength: 385), // priority 2
      SwingComponent(pivot: Vector2(355, 302), armLength: 385), // priority 2
      PlayerComponent(),                                  // priority 3
    ]);

    // ── Dynamic butterflies ──────────────────────────────────────────────
    _spawnButterflies();

    // ── UI overlay ──────────────────────────────────────────────────────
    overlays.add('HUD');
  }

  // ── Butterfly factory ─────────────────────────────────────────────────────

  static const List<Color> _wingColors = [
    Color(0xFFFF6B35), // orange monarch
    Color(0xFFFF69B4), // hot pink
    Color(0xFFFFD700), // golden yellow
    Color(0xFFDA70D6), // orchid purple
    Color(0xFF7CFC00), // lawn green
    Color(0xFF00BFFF), // deep sky blue
    Color(0xFFFF4500), // orange-red
    Color(0xFFADFF2F), // green-yellow
  ];

  void _spawnButterflies() {
    final rng = Random();
    for (int i = 0; i < 8; i++) {
      world.add(
        ButterflyComponent(
          startPosition: randomButterflyPoint(rng),
          wingColor: _wingColors[i % _wingColors.length],
        ),
      );
    }
  }

  /// Returns a random point in the upper portion of the scene,
  /// deliberately avoiding the cottage area (x 880-1420, y > 320).
  static Vector2 randomButterflyPoint(Random rng) {
    double x, y;
    do {
      x = rng.nextDouble() * (gameWidth - 100) + 50;
      y = rng.nextDouble() * 730 + 30;
    } while (_inCottageZone(x, y));
    return Vector2(x, y);
  }

  static bool _inCottageZone(double x, double y) =>
      x > 880 && x < 1420 && y > 320;
}
