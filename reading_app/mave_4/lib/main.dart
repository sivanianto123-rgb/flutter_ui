import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/enchanted_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    GameWidget<MyEnchantedGame>.controlled(
      gameFactory: MyEnchantedGame.new,
      overlayBuilderMap: {
        'HUD': (_, game) => _ControlsHUD(game: game),
      },
    ),
  );
}

// ── HUD overlay showing keyboard controls ────────────────────────────────────

class _ControlsHUD extends StatelessWidget {
  const _ControlsHUD({required this.game});
  final MyEnchantedGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _HudRow(icon: Icons.arrow_back, label: 'Arrow keys — walk'),
            _HudRow(icon: Icons.arrow_upward, label: 'Space — jump'),
            _HudRow(icon: Icons.swipe, label: 'Touch swing seat — kick'),
            _HudRow(icon: Icons.door_front_door, label: 'Walk into door — enter cottage'),
          ],
        ),
      ),
    );
  }
}

class _HudRow extends StatelessWidget {
  const _HudRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
