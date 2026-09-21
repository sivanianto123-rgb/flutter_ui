import '../utils/common_imports.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onTap;

  const ScheduleCard({super.key, required this.schedule, required this.onTap});

  IconData get _icon {
    switch (schedule.type) {
      case ScheduleType.meeting:
        return Icons.groups_rounded;
      case ScheduleType.appointment:
        return Icons.calendar_today_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  Color get _typeColor {
    switch (schedule.type) {
      case ScheduleType.meeting:
        return const Color(0xFF4A9EFF);
      case ScheduleType.appointment:
        return const Color(0xFF9B59B6);
      default:
        return AppColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: schedule.isCompleted ? AppColors.completed : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _typeColor.withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _typeColor, size: 20),
            ),
            SB.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: schedule.isCompleted
                        ? AppFonts.w400w14Strike
                        : AppFonts.w500w16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SB.h4,
                  Row(
                    children: [
                      if (schedule.time != null) ...[
                        Icon(Icons.access_time_rounded,
                            size: 12, color: AppColors.grey),
                        SB.w4,
                        Text(schedule.time!, style: AppFonts.w400g12),
                        SB.w12,
                      ],
                      if (schedule.location != null) ...[
                        Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.grey),
                        SB.w4,
                        Text(schedule.location!, style: AppFonts.w400g12),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  context.read<ScheduleProvider>().toggleComplete(schedule.id),
              child: Icon(
                schedule.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color:
                    schedule.isCompleted ? AppColors.orange : AppColors.grey,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
