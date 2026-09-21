import '../../utils/common_imports.dart';

class RecipeEditor extends StatefulWidget {
  final List<String> ingredients;
  final List<String> steps;
  final ValueChanged<List<String>> onIngredientsChanged;
  final ValueChanged<List<String>> onStepsChanged;

  const RecipeEditor({
    super.key,
    required this.ingredients,
    required this.steps,
    required this.onIngredientsChanged,
    required this.onStepsChanged,
  });

  @override
  State<RecipeEditor> createState() => _RecipeEditorState();
}

class _RecipeEditorState extends State<RecipeEditor> {
  late List<String> _ingredients;
  late List<String> _steps;
  final _ingCtrl = TextEditingController();
  final _stepCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.ingredients);
    _steps = List.from(widget.steps);
  }

  void _addIngredient() {
    if (_ingCtrl.text.trim().isEmpty) return;
    setState(() => _ingredients.add(_ingCtrl.text.trim()));
    _ingCtrl.clear();
    widget.onIngredientsChanged(_ingredients);
  }

  void _addStep() {
    if (_stepCtrl.text.trim().isEmpty) return;
    setState(() => _steps.add(_stepCtrl.text.trim()));
    _stepCtrl.clear();
    widget.onStepsChanged(_steps);
  }

  Widget _listSection(
      String label, List<String> items, TextEditingController ctrl,
      VoidCallback onAdd, ValueChanged<List<String>> onRemove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.w400g14),
        SB.h6,
        ...items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('${e.key + 1}. ', style: AppFonts.w400g12),
                  Expanded(child: Text(e.value, style: AppFonts.w400w14)),
                  GestureDetector(
                    onTap: () {
                      setState(() => items.removeAt(e.key));
                      onRemove(items);
                    },
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.grey, size: 16),
                  ),
                ],
              ),
            )),
        SB.h6,
        _AddRow(controller: ctrl, hint: 'Add...', onAdd: onAdd),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _listSection('Ingredients', _ingredients, _ingCtrl, _addIngredient,
            widget.onIngredientsChanged),
        SB.h16,
        _listSection(
            'Steps', _steps, _stepCtrl, _addStep, widget.onStepsChanged),
      ],
    );
  }
}

class _AddRow extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onAdd;

  const _AddRow(
      {required this.controller, required this.hint, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: AppFonts.w400w14,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppFonts.w400g14,
              filled: true,
              fillColor: AppColors.cardBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.orange),
              ),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        SB.w8,
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_rounded,
                color: AppColors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
