import 'package:uuid/uuid.dart';
import '../utils/common_imports.dart';
import '../models/note_model.dart';
import '../models/checklist_item.dart';
import '../providers/note_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/action_button.dart';
import 'sections/note_type_selector.dart';
import 'sections/checklist_editor.dart';
import 'sections/recipe_editor.dart';

class AddNoteScreen extends StatefulWidget {
  final DateTime date;
  final NoteModel? existing;
  final NoteType? initialType;

  const AddNoteScreen(
      {super.key, required this.date, this.existing, this.initialType});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late NoteType _type;
  late final TextEditingController _title;
  late final TextEditingController _content;
  late List<ChecklistItem> _checklist;
  late List<String> _ingredients;
  late List<String> _steps;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? widget.initialType ?? NoteType.note;
    _title = TextEditingController(text: e?.title ?? '');
    _content = TextEditingController(text: e?.content ?? '');
    _checklist = List.from(e?.checklist ?? []);
    _ingredients = List.from(e?.ingredients ?? []);
    _steps = List.from(e?.steps ?? []);
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    final note = NoteModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      content: _content.text.trim(),
      type: _type,
      date: widget.date,
      isCompleted: widget.existing?.isCompleted ?? false,
      checklist: _checklist,
      ingredients: _ingredients,
      steps: _steps,
    );
    final provider = context.read<NoteProvider>();
    widget.existing != null ? provider.update(note) : provider.add(note);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenTitle(
                    label: widget.existing != null ? 'Edit Note' : 'New Note'),
                SB.h24,
                NoteTypeSelector(
                  selected: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
                SB.h20,
                CustomTextField(
                    label: 'Title', controller: _title, hint: 'Enter title'),
                SB.h16,
                if (_type == NoteType.note)
                  CustomTextField(
                    label: 'Content',
                    controller: _content,
                    maxLines: 6,
                    hint: 'Write your note...',
                  ),
                if (_type == NoteType.checklist)
                  ChecklistEditor(
                    items: _checklist,
                    onChanged: (items) => setState(() => _checklist = items),
                  ),
                if (_type == NoteType.recipe)
                  RecipeEditor(
                    ingredients: _ingredients,
                    steps: _steps,
                    onIngredientsChanged: (v) =>
                        setState(() => _ingredients = v),
                    onStepsChanged: (v) => setState(() => _steps = v),
                  ),
                SB.h32,
                ActionButton(label: 'Save', onTap: _save),
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
        ],
      ),
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  final String label;
  const _ScreenTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label, style: AppFonts.w700w24));
  }
}
