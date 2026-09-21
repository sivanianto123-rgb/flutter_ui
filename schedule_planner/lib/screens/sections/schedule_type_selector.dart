import '../../utils/common_imports.dart';
import '../../models/schedule_model.dart';
import '../../widgets/type_chip.dart';

class ScheduleTypeSelector extends StatelessWidget {
  final ScheduleType selected;
  final ValueChanged<ScheduleType> onChanged;

  const ScheduleTypeSelector(
      {super.key, required this.selected, required this.onChanged});

  String _label(ScheduleType t) {
    switch (t) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type', style: AppFonts.w400g14),
        SB.h8,
        Row(
          children: ScheduleType.values
              .map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TypeChip(
                      label: _label(t),
                      isSelected: selected == t,
                      onTap: () => onChanged(t),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
