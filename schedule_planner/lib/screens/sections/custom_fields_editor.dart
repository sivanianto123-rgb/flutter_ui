import '../../utils/common_imports.dart';

class CustomFieldsEditor extends StatefulWidget {
  final List<String> fieldKeys;
  final Map<String, String> fieldValues;
  final ValueChanged<List<String>> onKeysChanged;
  final ValueChanged<Map<String, String>> onValuesChanged;

  const CustomFieldsEditor({
    super.key,
    required this.fieldKeys,
    required this.fieldValues,
    required this.onKeysChanged,
    required this.onValuesChanged,
  });

  @override
  State<CustomFieldsEditor> createState() => _CustomFieldsEditorState();
}

class _CustomFieldsEditorState extends State<CustomFieldsEditor> {
  late List<String> _keys;
  late Map<String, String> _values;
  final _keyCtrl = TextEditingController();
  final Map<String, TextEditingController> _valCtrls = {};

  @override
  void initState() {
    super.initState();
    _keys = List.from(widget.fieldKeys);
    _values = Map.from(widget.fieldValues);
    for (final k in _keys) {
      _valCtrls[k] = TextEditingController(text: _values[k] ?? '');
    }
  }

  void _addField() {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty || _keys.contains(key)) return;
    setState(() {
      _keys.add(key);
      _values[key] = '';
      _valCtrls[key] = TextEditingController();
      _keyCtrl.clear();
    });
    widget.onKeysChanged(_keys);
  }

  void _removeField(String key) {
    setState(() {
      _keys.remove(key);
      _values.remove(key);
      _valCtrls.remove(key);
    });
    widget.onKeysChanged(_keys);
    widget.onValuesChanged(_values);
  }

  void _updateValue(String key, String val) {
    _values[key] = val;
    widget.onValuesChanged(_values);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Custom Fields', style: AppFonts.w400g14),
        SB.h8,
        ..._keys.map((k) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(k, style: AppFonts.w500w16),
                  ),
                  SB.w8,
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _valCtrls[k],
                      style: AppFonts.w400w14,
                      onChanged: (v) => _updateValue(k, v),
                      decoration: InputDecoration(
                        hintText: 'Value',
                        hintStyle: AppFonts.w400g14,
                        filled: true,
                        fillColor: AppColors.cardBg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
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
                    ),
                  ),
                  SB.w8,
                  GestureDetector(
                    onTap: () => _removeField(k),
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
                controller: _keyCtrl,
                style: AppFonts.w400w14,
                decoration: InputDecoration(
                  hintText: 'Field name...',
                  hintStyle: AppFonts.w400g14,
                  filled: true,
                  fillColor: AppColors.cardBg,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
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
                onSubmitted: (_) => _addField(),
              ),
            ),
            SB.w8,
            GestureDetector(
              onTap: _addField,
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
