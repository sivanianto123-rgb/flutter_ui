import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../enchanted_game.dart';

/// An invisible collision plane sitting exactly on the top edge of the
/// wooden floor planks (y = [MyEnchantedGame.groundY]).
///
/// Phase 1 estimate: floor top edge at y ≈ 830 in 1920×1080 logical space.
///
/// The component is 250 px tall so the player never tunnels through
/// the floor at low frame-rates.
class GroundComponent extends PositionComponent with CollisionCallbacks {
  GroundComponent()
      : super(
          position: Vector2(0, MyEnchantedGame.groundY),
          size: Vector2(MyEnchantedGame.gameWidth, 250),
          priority: 1,
        );

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: size,
        position: Vector2.zero(),
      )..anchor = Anchor.topLeft,
    );
  }
}
