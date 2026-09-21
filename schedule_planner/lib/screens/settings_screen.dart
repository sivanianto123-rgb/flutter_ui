import '../utils/common_imports.dart';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';
import '../providers/schedule_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Settings', style: AppFonts.w700w24),
            ),
            SB.h24,
            _SectionLabel(label: 'Appearance'),
            _SettingsTile(
              icon: isDark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              iconColor: AppColors.orange,
              title: 'Theme',
              trailing: Switch(
                value: isDark,
                onChanged: (_) =>
                    context.read<ThemeProvider>().toggle(),
                activeThumbColor: AppColors.orange,
                activeTrackColor: AppColors.orange,
                inactiveThumbColor: AppColors.grey,
                inactiveTrackColor: AppColors.darkGrey,
              ),
            ),
            SB.h16,
            _SectionLabel(label: 'Data'),
            _SettingsTile(
              icon: Icons.delete_sweep_rounded,
              iconColor: Colors.red,
              title: 'Clear all notes',
              onTap: () => _confirmClear(context, 'Clear all notes?', () {
                // iterate and delete - provider handles persistence
                final notes = context.read<NoteProvider>().notes.toList();
                for (final n in notes) {
                  context.read<NoteProvider>().delete(n.id);
                }
              }),
            ),
            _SettingsTile(
              icon: Icons.event_busy_rounded,
              iconColor: Colors.red,
              title: 'Clear all schedules',
              onTap: () =>
                  _confirmClear(context, 'Clear all schedules?', () {
                final sched =
                    context.read<ScheduleProvider>().schedules.toList();
                for (final s in sched) {
                  context.read<ScheduleProvider>().delete(s.id);
                }
              }),
            ),
            SB.h16,
            _SectionLabel(label: 'About'),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.grey,
              title: 'Version',
              subtitle: '1.0.0',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(
      BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            ctx.isDark ? AppColors.cardBg : AppColors.lightCard,
        title: Text(message, style: AppFonts.w600w18),
        content: Text('This cannot be undone.', style: AppFonts.w400g14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppFonts.w500g14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text('Delete',
                style: AppFonts.w500o14.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Text(label.toUpperCase(),
          style: AppFonts.w400g12.copyWith(letterSpacing: 1.2)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: AppFonts.w500w16),
      subtitle: subtitle != null ? Text(subtitle!, style: AppFonts.w400g12) : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded, color: AppColors.grey)
              : null),
    );
  }
}
