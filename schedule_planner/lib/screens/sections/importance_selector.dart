import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_fonts.dart';
import '../../utils/sized_boxes.dart';

class ImportanceSelector extends StatelessWidget {
  final ScheduleImportance selected;
  final ValueChanged<ScheduleImportance> onChanged;

  const ImportanceSelector(
      {super.key, required this.selected, required this.onChanged});

  static Color colorFor(ScheduleImportance imp) {
    switch (imp) {
      case ScheduleImportance.low:
        return AppColors.importanceLow;
      case ScheduleImportance.medium:
        return AppColors.importanceMedium;
      case ScheduleImportance.high:
        return AppColors.importanceHigh;
      case ScheduleImportance.critical:
        return AppColors.importanceCritical;
    }
  }

  static String labelFor(ScheduleImportance imp) {
    switch (imp) {
      case ScheduleImportance.low:
        return 'Low';
      case ScheduleImportance.medium:
        return 'Medium';
      case ScheduleImportance.high:
        return 'High';
      case ScheduleImportance.critical:
        return 'Critical';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Importance', style: AppFonts.w400g14),
        SB.h8,
        Row(
          children: ScheduleImportance.values.map((imp) {
            final isSelected = selected == imp;
            final color = colorFor(imp);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(imp),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withAlpha(40)
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    labelFor(imp),
                    style: AppFonts.w400w12.copyWith(
                      color: isSelected ? color : AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
