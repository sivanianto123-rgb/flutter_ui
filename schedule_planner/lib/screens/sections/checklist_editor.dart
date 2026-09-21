import 'package:uuid/uuid.dart';
import '../../utils/common_imports.dart';
import '../../models/checklist_item.dart';

class ChecklistEditor extends StatefulWidget {
  final List<ChecklistItem> items;
  final ValueChanged<List<ChecklistItem>> onChanged;

  const ChecklistEditor(
      {super.key, required this.items, required this.onChanged});

  @override
  State<ChecklistEditor> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends State<ChecklistEditor> {
  late List<ChecklistItem> _items;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  void _add() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _items.add(ChecklistItem(id: const Uuid().v4(), text: _ctrl.text.trim()));
      _ctrl.clear();
    });
    widget.onChanged(_items);
  }

  void _remove(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
    widget.onChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Checklist Items', style: AppFonts.w400g14),
        SB.h8,
        ..._items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.drag_indicator_rounded,
                      color: AppColors.grey, size: 18),
                  SB.w8,
                  Expanded(
                      child: Text(item.text, style: AppFonts.w400w14)),
                  GestureDetector(
                    onTap: () => _remove(item.id),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.grey, size: 18),
                  ),
                ],
              ),
            )),
        SB.h8,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: AppFonts.w400w14,
                decoration: InputDecoration(
                  hintText: 'Add item...',
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
                onSubmitted: (_) => _add(),
              ),
            ),
            SB.w8,
            GestureDetector(
              onTap: _add,
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
        ),
      ],
    );
  }
}
