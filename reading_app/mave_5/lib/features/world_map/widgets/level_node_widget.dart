import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level_node.dart';

class LevelNodeWidget extends StatefulWidget {
  final LevelNode node;
  final VoidCallback onTap;

  const LevelNodeWidget({super.key, required this.node, required this.onTap});

  @override
  State<LevelNodeWidget> createState() => _LevelNodeWidgetState();
}

class _LevelNodeWidgetState extends State<LevelNodeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.node.state == NodeState.current) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCircle() {
    final node = widget.node;
    final isCurrent = node.state == NodeState.current;
    final isLocked = node.state == NodeState.locked;

    final outerDia = isCurrent ? 66.0 : 62.0;
    final innerDia = isCurrent ? 54.0 : 50.0;

    final outerColor = isLocked ? const Color(0xFF78AEDA) : const Color(0xFF1976D2);
    final innerColor = isLocked ? const Color(0xFF90BFE8) : const Color(0xFF42A5F5);

    Widget circle = Container(
      width: outerDia,
      height: outerDia,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outerColor,
        border: Border.all(
          color: isLocked ? const Color(0xFF5A9AC8) : const Color(0xFF0D47A1),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Container(
          width: innerDia,
          height: innerDia,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: innerColor,
          ),
          child: Center(
            child: isLocked
                ? const Icon(Icons.lock_rounded, color: Colors.white, size: 22)
                : Text(
                    '${node.id}',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );

    if (isCurrent) {
      circle = AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Transform.scale(
          scale: _pulse.value,
          child: Container(
            width: outerDia,
            height: outerDia,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: outerColor,
              border: Border.all(color: const Color(0xFF0D47A1), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.6 * _pulse.value),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: innerDia,
                height: innerDia,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF42A5F5),
                ),
                child: Center(
                  child: Text(
                    '${node.id}',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return circle;
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (node.state == NodeState.completed)
            _StarsRow(stars: node.stars)
          else
            const SizedBox(height: 20),
          _buildCircle(),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int stars;
  const _StarsRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          color: const Color(0xFFFFD700),
          size: 18,
        );
      }),
    );
  }
}
