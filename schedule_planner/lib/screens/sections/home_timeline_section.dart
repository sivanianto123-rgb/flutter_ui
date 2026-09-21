import '../../utils/common_imports.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/date_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/timeline_view.dart';
import '../add_schedule_screen.dart';

class HomeTimelineSection extends StatelessWidget {
  const HomeTimelineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final date = context.watch<DateProvider>().selectedDate;
    final schedules = context.watch<ScheduleProvider>().forDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SB.h20,
        SectionHeader(
          title: 'Timeline',
          actionLabel: '+ Add',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddScheduleScreen(date: date)),
          ),
        ),
        SB.h16,
        TimelineView(schedules: schedules),
      ],
    );
  }
}
