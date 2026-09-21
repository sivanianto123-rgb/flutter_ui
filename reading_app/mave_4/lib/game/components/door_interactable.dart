import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import 'player_component.dart';

/// Invisible hitbox placed over the yellow arched door on the blue cottage.
///
/// Phase 1 coordinate estimate (1920×1080):
///   position : x = 1085, y = 545
///   size     : w = 125,  h = 285
///
/// Prints a placeholder message on player contact.
/// Replace the [debugPrint] call with your level-router logic.
class DoorInteractable extends PositionComponent with CollisionCallbacks {
  DoorInteractable()
      : super(
          position: Vector2(1085, 545),
          size: Vector2(125, 285),
          priority: 2,
        );

  bool _triggered = false;

  @override
  Future<void> onLoad() async {
    // Fill the entire component with the hitbox.
    // Set debugMode = true during development to see the red outline.
    add(RectangleHitbox()..debugMode = kDebugMode);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is PlayerComponent && !_triggered) {
      _triggered = true;
      debugPrint('🏠 Entering Cottage — [PLACEHOLDER: push CottageLevel route]');
      // TODO: gameRef.router.push(CottageLevelRoute());
      // TODO: FlameAudio.play('door_open.mp3');
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is PlayerComponent) _triggered = false;
  }
}
