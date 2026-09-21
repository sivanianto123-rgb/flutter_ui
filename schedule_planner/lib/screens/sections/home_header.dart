import 'package:intl/intl.dart';
import '../../utils/common_imports.dart';
import '../../providers/date_provider.dart';
import '../../widgets/date_strip.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final date = context.watch<DateProvider>().selectedDate;
    final isToday = DateProvider().isSameDay(date, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Today' : DateFormat('EEEE').format(date),
                    style: AppFonts.w700w24,
                  ),
                  Text(
                    DateFormat('MMMM d, yyyy').format(date),
                    style: AppFonts.w400g14,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.orange,
                          surface: AppColors.cardBg,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null && context.mounted) {
                    context.read<DateProvider>().setDate(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.dividerC),
                  ),
                  child: const Icon(Icons.calendar_month_rounded,
                      color: AppColors.orange, size: 22),
                ),
              ),
            ],
          ),
        ),
        SB.h12,
        const DateStrip(),
        SB.h8,
        AppDividers.dark,
      ],
    );
  }
}
