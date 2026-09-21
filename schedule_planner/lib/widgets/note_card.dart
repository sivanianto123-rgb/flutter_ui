import '../utils/common_imports.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  IconData get _icon {
    switch (note.type) {
      case NoteType.checklist:
        return Icons.checklist_rounded;
      case NoteType.recipe:
        return Icons.restaurant_menu_rounded;
      default:
        return Icons.sticky_note_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: note.isCompleted ? AppColors.completed : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, color: AppColors.orange, size: 16),
                SB.w8,
                Expanded(
                  child: Text(
                    note.title,
                    style: note.isCompleted
                        ? AppFonts.w400w14Strike
                        : AppFonts.w500w16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<NoteProvider>().toggleComplete(note.id),
                  child: Icon(
                    note.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: note.isCompleted ? AppColors.orange : AppColors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (note.content.isNotEmpty) ...[
              SB.h8,
              Text(
                note.content,
                style: AppFonts.w400g12,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (note.type == NoteType.checklist && note.checklist.isNotEmpty) ...[
              SB.h8,
              Text(
                '${note.checklist.where((c) => c.isChecked).length}/${note.checklist.length} done',
                style: AppFonts.w400g12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
