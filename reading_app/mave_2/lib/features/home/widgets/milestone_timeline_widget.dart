import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/milestone_node.dart';

/// Horizontally scrollable Adaptive Milestone Timeline.
///
/// Renders [MilestoneNode.curriculum] as a connected sequence of interactive
/// circles (individual nodes) and rounded rectangles (bridge nodes):
///
///   O ── O ── ◆ ── O ── O ── ◆ ── O ── O ── ◆
///   Ma  Pa  Ma+Pa  Ba   Da  Ba+Da  Na  Ka  Na+Ka
///
/// Node states:
///   [NodeStatus.locked]     — grey, padlock icon, not tappable
///   [NodeStatus.available]  — coloured, gentle pulse, tappable
///   [NodeStatus.inProgress] — coloured with progress ring, tappable
///   [NodeStatus.mastered]   — green with checkmark, tappable (for review)
///
/// Connector lines are coloured when the left node is mastered/inProgress.
class MilestoneTimelineWidget extends StatelessWidget {
  const MilestoneTimelineWidget({
    super.key,
    required this.levelProgress,
    required this.onNodeTap,
  });

  /// Child's current level map (syllable → 0–3). Source: [ChildProfile].
  final Map<String, int> levelProgress;

  /// Invoked when the user taps an unlocked node.
  final void Function(MilestoneNode node) onNodeTap;

  @override
  Widget build(BuildContext context) {
    final nodes = MilestoneNode.curriculum;

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        // Each pair: node + connector (last node has no trailing connector).
        itemCount: nodes.length * 2 - 1,
        itemBuilder: (context, i) {
          if (i.isOdd) {
            final left  = nodes[i ~/ 2];
            final right = nodes[(i ~/ 2) + 1];
            final leftDone = _isActive(left.statusFor(levelProgress));
            return _Connector(
              active:        leftDone,
              isBridgeEdge:  right.type == NodeType.bridge ||
                             left.type  == NodeType.bridge,
            );
          }

          final node   = nodes[i ~/ 2];
          final status = node.statusFor(levelProgress);
          final tappable = status == NodeStatus.available ||
                           status == NodeStatus.inProgress ||
                           status == NodeStatus.mastered;

          return _NodeTile(
            node:    node,
            status:  status,
            index:   i ~/ 2,
            onTap:   tappable ? () => onNodeTap(node) : null,
          );
        },
      ),
    );
  }

  static bool _isActive(NodeStatus s) =>
      s == NodeStatus.mastered || s == NodeStatus.inProgress;
}

// ── Connector line ─────────────────────────────────────────────────────────────

class _Connector extends StatelessWidget {
  const _Connector({required this.active, required this.isBridgeEdge});

  final bool active;
  final bool isBridgeEdge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          height: 5,
          width:  28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: active
                ? (isBridgeEdge ? AppColors.accent : AppColors.primary.withAlpha(210))
                : Colors.grey.withAlpha(55),
          ),
        ),
      ),
    );
  }
}

// ── Single node tile ───────────────────────────────────────────────────────────

class _NodeTile extends StatelessWidget {
  const _NodeTile({
    required this.node,
    required this.status,
    required this.index,
    this.onTap,
  });

  final MilestoneNode node;
  final NodeStatus    status;
  final int           index;
  final VoidCallback? onTap;

  static const double _individualSize = 86;
  static const double _bridgeSize     = 100;

  @override
  Widget build(BuildContext context) {
    final isBridge = node.type == NodeType.bridge;
    final isLocked = status == NodeStatus.locked;
    final size     = isBridge ? _bridgeSize : _individualSize;

    final (Color bg, Color border, Color labelColor) = switch (status) {
      NodeStatus.mastered   => (
          AppColors.accentGreen.withAlpha(210),
          AppColors.accentGreen,
          Colors.white,
        ),
      NodeStatus.inProgress => (
          AppColors.primary.withAlpha(70),
          AppColors.primary,
          AppColors.textDark,
        ),
      NodeStatus.available  => (
          Colors.white,
          isBridge ? AppColors.accent : AppColors.secondary,
          AppColors.textDark,
        ),
      NodeStatus.locked     => (
          Colors.grey.withAlpha(38),
          Colors.grey.withAlpha(70),
          Colors.grey,
        ),
    };

    Widget badge = _NodeBadge(
      node:         node,
      size:         size,
      isBridge:     isBridge,
      isLocked:     isLocked,
      bg:           bg,
      border:       border,
      labelColor:   labelColor,
      mastered:     status == NodeStatus.mastered,
      onTap:        onTap,
    );

    // Gentle pulse for available nodes to draw the baby's eye.
    if (status == NodeStatus.available) {
      badge = badge
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end:   const Offset(1.05, 1.05),
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: badge
          .animate(delay: Duration(milliseconds: index * 70))
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOut),
    );
  }
}

class _NodeBadge extends StatelessWidget {
  const _NodeBadge({
    required this.node,
    required this.size,
    required this.isBridge,
    required this.isLocked,
    required this.bg,
    required this.border,
    required this.labelColor,
    required this.mastered,
    required this.onTap,
  });

  final MilestoneNode node;
  final double        size;
  final bool          isBridge;
  final bool          isLocked;
  final Color         bg;
  final Color         border;
  final Color         labelColor;
  final bool          mastered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Node body ─────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            width:  size,
            height: size,
            decoration: BoxDecoration(
              color:        bg,
              shape: isBridge ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isBridge ? BorderRadius.circular(22) : null,
              border:       Border.all(color: border, width: isBridge ? 3 : 2.5),
              boxShadow: isLocked
                  ? []
                  : [
                      BoxShadow(
                        color:      border.withAlpha(90),
                        blurRadius: 14,
                        offset:     const Offset(0, 5),
                      ),
                    ],
            ),
            child: Center(
              child: isLocked
                  ? Icon(Icons.lock_rounded,
                      color: Colors.grey.withAlpha(110), size: 30)
                  : mastered
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(node.emoji,
                                style: TextStyle(
                                    fontSize: isBridge ? 26 : 30)),
                            const SizedBox(height: 2),
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 18),
                          ],
                        )
                      : Text(node.emoji,
                          style:
                              TextStyle(fontSize: isBridge ? 28 : 34)),
            ),
          ),

          const SizedBox(height: 6),

          // ── Label ─────────────────────────────────────────────────────────
          SizedBox(
            width: size + 8,
            child: Text(
              node.label,
              textAlign: TextAlign.center,
              maxLines:  2,
              overflow:  TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color:      labelColor,
                fontWeight: isBridge ? FontWeight.w800 : FontWeight.w600,
                fontSize:   isBridge ? 12 : 13,
                height:     1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
