import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../phonics/phonics_forest_background.dart';
import 'cartoon_progress_bar.dart';

class ZoneShell extends ConsumerWidget {
  const ZoneShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.checkpointCount,
    required this.currentCheckpoint,
    required this.child,
    this.onCheckpointTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final int checkpointCount;
  final int currentCheckpoint;
  final Widget child;
  final ValueChanged<int>? onCheckpointTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          const PhonicsForestBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CartoonProgressBar(
                          value: progress.clamp(0.0, 1.0),
                          height: 28,
                          checkpointCount: checkpointCount,
                          currentCheckpoint: currentCheckpoint,
                          onCheckpointTap: onCheckpointTap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: const Icon(Icons.home_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                    ),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
