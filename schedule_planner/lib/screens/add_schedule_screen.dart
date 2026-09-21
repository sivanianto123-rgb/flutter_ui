import 'package:uuid/uuid.dart';
import '../utils/common_imports.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/action_button.dart';
import 'sections/schedule_type_selector.dart';
import 'sections/importance_selector.dart';
import 'sections/custom_fields_editor.dart';

class AddScheduleScreen extends StatefulWidget {
  final DateTime date;
  final ScheduleModel? existing;

  const AddScheduleScreen({super.key, required this.date, this.existing});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  late ScheduleType _type;
  late ScheduleImportance _importance;
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _attendees;
  late final TextEditingController _meetingLink;
  String? _time;
  late List<String> _customKeys;
  late Map<String, String> _customValues;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? ScheduleType.meeting;
    _importance = e?.importance ?? ScheduleImportance.medium;
    _title = TextEditingController(text: e?.title ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _attendees = TextEditingController(text: e?.attendees.join(', ') ?? '');
    _meetingLink = TextEditingController(text: e?.meetingLink ?? '');
    _time = e?.time;
    _customKeys = List.from(e?.customFieldKeys ?? []);
    _customValues = Map.from(e?.customFieldValues ?? {});
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _attendees.dispose();
    _meetingLink.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (picked != null && mounted) {
      setState(() => _time = picked.format(context));
    }
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    final attendeeList = _attendees.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final schedule = ScheduleModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      date: widget.date,
      time: _time,
      type: _type,
      importance: _importance,
      meetingLink: _meetingLink.text.trim().isNotEmpty
          ? _meetingLink.text.trim()
          : null,
      location:
          _location.text.trim().isNotEmpty ? _location.text.trim() : null,
      description: _description.text.trim().isNotEmpty
          ? _description.text.trim()
          : null,
      attendees: attendeeList,
      isCompleted: widget.existing?.isCompleted ?? false,
      customFieldKeys: _customKeys,
      customFieldValues: _customValues,
    );

    final provider = context.read<ScheduleProvider>();
    widget.existing != null ? provider.update(schedule) : provider.add(schedule);
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
                Center(
                  child: Text(
                    widget.existing != null ? 'Edit Schedule' : 'New Schedule',
                    style: AppFonts.w700w24,
                  ),
                ),
                SB.h24,
                ScheduleTypeSelector(
                    selected: _type,
                    onChanged: (t) => setState(() => _type = t)),
                SB.h16,
                ImportanceSelector(
                    selected: _importance,
                    onChanged: (i) => setState(() => _importance = i)),
                SB.h20,
                CustomTextField(
                    label: 'Title', controller: _title, hint: 'Enter title'),
                SB.h16,
                _TimePicker(time: _time, onTap: _pickTime),
                SB.h16,
                CustomTextField(
                    label: 'Location',
                    controller: _location,
                    hint: 'Optional location'),
                SB.h16,
                CustomTextField(
                    label: 'Description',
                    controller: _description,
                    maxLines: 3,
                    hint: 'Optional notes...'),
                if (_type == ScheduleType.meeting ||
                    _type == ScheduleType.custom) ...[
                  SB.h16,
                  CustomTextField(
                      label: 'Meeting Link',
                      controller: _meetingLink,
                      hint: 'https://...'),
                ],
                if (_type == ScheduleType.meeting) ...[
                  SB.h16,
                  CustomTextField(
                      label: 'Attendees',
                      controller: _attendees,
                      hint: 'Comma-separated names'),
                ],
                if (_type == ScheduleType.custom) ...[
                  SB.h20,
                  CustomFieldsEditor(
                    fieldKeys: _customKeys,
                    fieldValues: _customValues,
                    onKeysChanged: (k) => setState(() => _customKeys = k),
                    onValuesChanged: (v) => setState(() => _customValues = v),
                  ),
                ],
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

class _TimePicker extends StatelessWidget {
  final String? time;
  final VoidCallback onTap;
  const _TimePicker({this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time', style: AppFonts.w400g14),
        SB.h8,
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerC),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: AppColors.grey, size: 18),
                SB.w8,
                Text(time ?? 'Select time',
                    style: time != null ? AppFonts.w400w14 : AppFonts.w400g14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
