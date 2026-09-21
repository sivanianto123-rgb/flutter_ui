import 'package:intl/intl.dart';
import '../utils/common_imports.dart';
import '../providers/date_provider.dart';

class DateStrip extends StatefulWidget {
  const DateStrip({super.key});

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late ScrollController _scroll;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    final now = DateTime.now();
    _days = List.generate(60, (i) => now.subtract(Duration(days: 30 - i)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scroll.jumpTo(30 * 60.0);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DateProvider>();
    final selected = provider.selectedDate;
    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (_, i) => _DayChip(
          date: _days[i],
          isSelected: provider.isSameDay(_days[i], selected),
          onTap: () => provider.setDate(_days[i]),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip(
      {required this.date, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('EEE').format(date),
                style: isSelected
                    ? AppFonts.w400w12.copyWith(color: AppColors.white)
                    : AppFonts.w400g12),
            SB.h4,
            Text(date.day.toString(),
                style: isSelected
                    ? AppFonts.w600w18.copyWith(color: AppColors.white)
                    : AppFonts.w500w16),
          ],
        ),
      ),
    );
  }
}
