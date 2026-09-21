import '../utils/common_imports.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import '../screens/sections/importance_selector.dart';

class TimelineView extends StatelessWidget {
  final List<ScheduleModel> schedules;

  const TimelineView({super.key, required this.schedules});

  static int _toMinutes(String? t) {
    if (t == null) return 24 * 60;
    final lower = t.toLowerCase();
    final isPm = lower.contains('pm');
    final clean = lower.replaceAll('am', '').replaceAll('pm', '').trim();
    final parts = clean.split(':');
    int h = int.tryParse(parts[0]) ?? 0;
    int m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    if (isPm && h != 12) h += 12;
    if (!isPm && h == 12) h = 0;
    return h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...schedules]
      ..sort((a, b) => _toMinutes(a.time).compareTo(_toMinutes(b.time)));

    final timed = sorted.where((s) => s.time != null).toList();
    final untimed = sorted.where((s) => s.time == null).toList();

    if (schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('No scheduled items for this day',
            style: AppFonts.w400g14),
      );
    }

    return Column(
      children: [
        ...timed.asMap().entries.map((entry) => _TimelineItem(
              schedule: entry.value,
              isLast: entry.key == timed.length - 1 && untimed.isEmpty,
            )),
        if (untimed.isNotEmpty) ...[
          SB.h8,
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text('Unscheduled', style: AppFonts.w400g12),
          ),
          SB.h8,
          ...untimed.map((s) => _TimelineItem(
                schedule: s,
                isLast: s == untimed.last,
                showTime: false,
              )),
        ],
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ScheduleModel schedule;
  final bool isLast;
  final bool showTime;

  const _TimelineItem({
    required this.schedule,
    required this.isLast,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final impColor = ImportanceSelector.colorFor(schedule.importance);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 8),
              child: Text(
                showTime ? (schedule.time ?? '') : '—',
                style: AppFonts.w400g12,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  color: schedule.isCompleted ? AppColors.grey : AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.dividerC,
                  ),
                ),
            ],
          ),
          SB.w12,
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<ScheduleProvider>().toggleComplete(schedule.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: schedule.isCompleted
                      ? context.completedC
                      : context.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.dividerC),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            schedule.title,
                            style: schedule.isCompleted
                                ? AppFonts.w400w14Strike
                                : AppFonts.w500w16,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: impColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    if (schedule.location != null) ...[
                      SB.h4,
                      Row(children: [
                        Icon(Icons.location_on_rounded,
                            size: 11, color: AppColors.grey),
                        SB.w4,
                        Text(schedule.location!, style: AppFonts.w400g12),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SB.w16,
        ],
      ),
    );
  }
}
