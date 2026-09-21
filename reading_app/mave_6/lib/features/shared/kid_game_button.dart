import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Chunky, bubbly game-style button for toddler UI.
class KidGameButton extends StatefulWidget {
  const KidGameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFFFF6F61),
    this.secondaryColor,
    this.icon,
    this.width,
    this.enabled = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color? secondaryColor;
  final IconData? icon;
  final double? width;
  final bool enabled;
  final bool compact;

  @override
  State<KidGameButton> createState() => _KidGameButtonState();
}

class _KidGameButtonState extends State<KidGameButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onPressed != null;
    final top = widget.secondaryColor ?? _darken(widget.color, 0.12);
    final edge = _darken(widget.color, 0.28);
    final height = widget.compact ? 52.0 : 62.0;
    final fontSize = widget.compact ? 18.0 : 22.0;
    final pressOffset = _pressed && active ? 4.0 : 0.0;

    return GestureDetector(
      onTapDown: active ? (_) => setState(() => _pressed = true) : null,
      onTapUp: active
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: active ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        width: widget.width,
        height: height,
        transform: Matrix4.translationValues(0, pressOffset, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 6,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: edge,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: active
                        ? [top, widget.color]
                        : [Colors.grey.shade400, Colors.grey.shade500],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: active ? 0.55 : 0.25),
                    width: 2.5,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      right: 10,
                      top: 6,
                      child: Container(
                        height: height * 0.22,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: active ? 0.35 : 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: fontSize + 4,
                              shadows: const [
                                Shadow(
                                  color: Color(0x66000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: const [
                                Shadow(
                                  color: Color(0x88000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms);
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// Small letter tile used in games.
class KidLetterTile extends StatelessWidget {
  const KidLetterTile({
    super.key,
    required this.letter,
    required this.color,
    this.selected = false,
    this.sunk = false,
    this.onTap,
    this.size = 58,
  });

  final String letter;
  final Color color;
  final bool selected;
  final bool sunk;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: sunk ? null : onTap,
      child: AnimatedOpacity(
        opacity: sunk ? 0.35 : 1,
        duration: const Duration(milliseconds: 350),
        child: AnimatedScale(
          scale: sunk ? 0.7 : (selected ? 1.08 : 1),
          duration: const Duration(milliseconds: 280),
          curve: Curves.elasticOut,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: sunk
                    ? [const Color(0xFF90A4AE), const Color(0xFF607D8B)]
                    : [color.withValues(alpha: 0.95), _darken(color, 0.15)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 2.5,
              ),
              boxShadow: sunk
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Text(
              letter.toUpperCase(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Color(0x66000000), blurRadius: 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
