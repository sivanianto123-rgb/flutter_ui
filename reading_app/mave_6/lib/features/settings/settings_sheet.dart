import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/child_performance_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/progress_report_service.dart';

Future<void> showAppSettingsSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      final settings = ref.watch(appSettingsProvider);
      final notifier = ref.read(appSettingsProvider.notifier);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.volume_up_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: settings.volume,
                      onChanged: settings.isMuted ? null : notifier.setVolume,
                    ),
                  ),
                  Text(
                    '${(settings.volume * 100).round()}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              SwitchListTile(
                value: settings.isMuted,
                onChanged: notifier.setMuted,
                activeColor: const Color(0xFFFFD54F),
                contentPadding: EdgeInsets.zero,
                title: const Text('Mute', style: TextStyle(color: Colors.white)),
                secondary: const Icon(Icons.volume_off_rounded, color: Colors.white),
              ),
              SwitchListTile(
                value: settings.isDarkMode,
                onChanged: notifier.setDarkMode,
                activeColor: const Color(0xFF90CAF9),
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
                secondary: const Icon(Icons.nightlight_round, color: Colors.white),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final profile = ref.read(profileProvider).valueOrNull;
                    final performance = ref
                            .read(childPerformanceProvider)
                            .valueOrNull ??
                        const ChildPerformance();
                    if (profile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Create a child profile first.')),
                      );
                      return;
                    }
                    if (profile.parentEmail == null || profile.parentEmail!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add a parent email in onboarding.')),
                      );
                      return;
                    }
                    final sent = await ProgressReportService.emailReport(
                      profile: profile,
                      performance: performance,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          sent
                              ? 'Report email opened for ${profile.parentEmail}.'
                              : 'Could not open email app.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.email_rounded),
                  label: const Text('Send Parent Report'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
