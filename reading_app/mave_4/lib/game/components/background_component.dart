import 'package:flame/components.dart';

import '../enchanted_game.dart';

/// Renders the enchanted forest scene (assets/images/background.png)
/// as a single sprite filling the entire 1920×1080 logical canvas.
///
/// Phase 1 note: the image is used as-is; no secondary sprite layers are needed.
class BackgroundComponent extends SpriteComponent
    with HasGameRef<MyEnchantedGame> {
  BackgroundComponent() : super(priority: 0);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('background.png');
    size = Vector2(MyEnchantedGame.gameWidth, MyEnchantedGame.gameHeight);
    position = Vector2.zero();
  }
}
