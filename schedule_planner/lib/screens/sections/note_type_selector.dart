import '../../utils/common_imports.dart';
import '../../models/note_model.dart';
import '../../widgets/type_chip.dart';

class NoteTypeSelector extends StatelessWidget {
  final NoteType selected;
  final ValueChanged<NoteType> onChanged;

  const NoteTypeSelector(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type', style: AppFonts.w400g14),
        SB.h8,
        Row(
          children: NoteType.values
              .map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TypeChip(
                      label: t.name[0].toUpperCase() + t.name.substring(1),
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
