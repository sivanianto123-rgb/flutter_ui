import '../utils/common_imports.dart';
import '../models/note_model.dart';
import '../models/checklist_item.dart';
import '../providers/note_provider.dart';
import '../widgets/action_button.dart';
import 'add_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<NoteProvider>().notes.firstWhere(
          (n) => n.id == note.id,
          orElse: () => note,
        );

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    current.title,
                    style: current.isCompleted
                        ? AppFonts.w700w24.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.grey)
                        : AppFonts.w700w24,
                  ),
                ),
                SB.h24,
                if (current.type == NoteType.note && current.content.isNotEmpty)
                  Text(current.content, style: AppFonts.w400w14),
                if (current.type == NoteType.checklist)
                  _ChecklistView(note: current),
                if (current.type == NoteType.recipe)
                  _RecipeView(note: current),
                SB.h32,
                ActionButton(
                  label: current.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                  onTap: () =>
                      context.read<NoteProvider>().toggleComplete(current.id),
                ),
                SB.h12,
                ActionButton(
                  label: 'Delete',
                  isDestructive: true,
                  onTap: () {
                    context.read<NoteProvider>().delete(current.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 52,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white),
            ),
          ),
          Positioned(
            top: 52,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddNoteScreen(date: current.date, existing: current),
                ),
              ),
              icon: const Icon(Icons.edit_rounded, color: AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistView extends StatelessWidget {
  final NoteModel note;
  const _ChecklistView({required this.note});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: note.checklist
          .map((item) => _ChecklistTile(item: item, noteId: note.id))
          .toList(),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  final String noteId;

  const _ChecklistTile({required this.item, required this.noteId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final provider = context.read<NoteProvider>();
              final note = provider.notes.firstWhere((n) => n.id == noteId);
              final updated = note.checklist
                  .map((c) => c.id == item.id
                      ? c.copyWith(isChecked: !c.isChecked)
                      : c)
                  .toList();
              await provider.update(note.copyWith(checklist: updated));
            },
            child: Icon(
              item.isChecked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: item.isChecked ? AppColors.orange : AppColors.grey,
            ),
          ),
          SB.w12,
          Expanded(
            child: Text(
              item.text,
              style: item.isChecked ? AppFonts.w400w14Strike : AppFonts.w400w14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeView extends StatelessWidget {
  final NoteModel note;
  const _RecipeView({required this.note});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.ingredients.isNotEmpty) ...[
          Text('Ingredients', style: AppFonts.w600w18),
          SB.h8,
          ...note.ingredients.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Icon(Icons.circle, color: AppColors.orange, size: 6),
                  SB.w8,
                  Text(i, style: AppFonts.w400w14),
                ]),
              )),
          SB.h16,
        ],
        if (note.steps.isNotEmpty) ...[
          Text('Steps', style: AppFonts.w600w18),
          SB.h8,
          ...note.steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${e.key + 1}',
                          style: AppFonts.w400w12.copyWith(fontSize: 11)),
                    ),
                    SB.w10,
                    Expanded(child: Text(e.value, style: AppFonts.w400w14)),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
