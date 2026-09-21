import '../../utils/common_imports.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/date_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/schedule_card.dart';
import '../add_schedule_screen.dart';
import '../schedule_detail_screen.dart';

class HomeSchedulesSection extends StatelessWidget {
  const HomeSchedulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final date = context.watch<DateProvider>().selectedDate;
    final schedules = context.watch<ScheduleProvider>().forDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SB.h20,
        SectionHeader(
          title: 'Schedules',
          actionLabel: '+ Add',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddScheduleScreen(date: date),
            ),
          ),
        ),
        SB.h8,
        if (schedules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('No schedules for this day', style: AppFonts.w400g14),
          )
        else
          ...schedules.map(
            (s) => ScheduleCard(
              schedule: s,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScheduleDetailScreen(schedule: s),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
