import '../utils/common_imports.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import '../widgets/action_button.dart';
import '../screens/sections/importance_selector.dart';
import 'add_schedule_screen.dart';

class ScheduleDetailScreen extends StatelessWidget {
  final ScheduleModel schedule;
  const ScheduleDetailScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<ScheduleProvider>().schedules.firstWhere(
          (s) => s.id == schedule.id,
          orElse: () => schedule,
        );

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    current.title,
                    style: current.isCompleted
                        ? AppFonts.w700w24.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.grey)
                        : AppFonts.w700w24,
                    textAlign: TextAlign.center,
                  ),
                ),
                SB.h8,
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TypeBadge(type: current.type),
                      SB.w8,
                      _ImportanceBadge(importance: current.importance),
                    ],
                  ),
                ),
                SB.h24,
                if (current.time != null)
                  _DetailRow(
                      icon: Icons.access_time_rounded, value: current.time!),
                if (current.location != null)
                  _DetailRow(
                      icon: Icons.location_on_rounded,
                      value: current.location!),
                if (current.meetingLink != null)
                  _DetailRow(
                      icon: Icons.link_rounded,
                      value: current.meetingLink!),
                if (current.description != null &&
                    current.description!.isNotEmpty) ...[
                  SB.h8,
                  Text('Notes', style: AppFonts.w600w18),
                  SB.h8,
                  Text(current.description!, style: AppFonts.w400w14),
                ],
                if (current.type == ScheduleType.meeting &&
                    current.attendees.isNotEmpty) ...[
                  SB.h16,
                  Text('Attendees', style: AppFonts.w600w18),
                  SB.h8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: current.attendees
                        .map((a) => _AttendeeChip(name: a))
                        .toList(),
                  ),
                ],
                if (current.type == ScheduleType.custom &&
                    current.customFieldKeys.isNotEmpty) ...[
                  SB.h16,
                  Text('Details', style: AppFonts.w600w18),
                  SB.h8,
                  ...current.customFieldKeys.map((k) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text('$k: ', style: AppFonts.w500g14),
                            Text(current.customFieldValues[k] ?? '',
                                style: AppFonts.w400w14),
                          ],
                        ),
                      )),
                ],
                SB.h32,
                ActionButton(
                  label: current.isCompleted
                      ? 'Mark Incomplete'
                      : 'Mark Complete',
                  onTap: () => context
                      .read<ScheduleProvider>()
                      .toggleComplete(current.id),
                ),
                SB.h12,
                ActionButton(
                  label: 'Delete',
                  isDestructive: true,
                  onTap: () {
                    context.read<ScheduleProvider>().delete(current.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 52,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white),
            ),
          ),
          Positioned(
            top: 52,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AddScheduleScreen(
                      date: current.date, existing: current),
                ),
              ),
              icon: const Icon(Icons.edit_rounded, color: AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _DetailRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 18),
          SB.w8,
          Text(value, style: AppFonts.w400w14),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final ScheduleType type;
  const _TypeBadge({required this.type});

  String get label {
    switch (type) {
      case ScheduleType.meeting:
        return 'Meeting';
      case ScheduleType.appointment:
        return 'Appointment';
      case ScheduleType.custom:
        return 'Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.orange.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.orange.withAlpha(102)),
      ),
      child: Text(label, style: AppFonts.w500o14),
    );
  }
}

class _AttendeeChip extends StatelessWidget {
  final String name;
  const _AttendeeChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.dividerC),
      ),
      child: Text(name, style: AppFonts.w400w14),
    );
  }
}

class _ImportanceBadge extends StatelessWidget {
  final ScheduleImportance importance;
  const _ImportanceBadge({required this.importance});

  @override
  Widget build(BuildContext context) {
    final color = ImportanceSelector.colorFor(importance);
    final label = ImportanceSelector.labelFor(importance);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: AppFonts.w400w12.copyWith(color: color, fontSize: 12)),
    );
  }
}
