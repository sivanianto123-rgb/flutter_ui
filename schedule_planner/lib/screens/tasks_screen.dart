import 'package:intl/intl.dart';
import '../utils/common_imports.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_model.dart';
import '../providers/date_provider.dart';
import '../widgets/speed_dial_fab.dart';
import 'note_detail_screen.dart';
import 'schedule_detail_screen.dart';

enum _Filter { all, notes, checklists, recipes, schedules }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _Filter _filter = _Filter.all;
  bool _fabOpen = false;

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NoteProvider>().notes;
    final schedules = context.watch<ScheduleProvider>().schedules;
    final date = context.watch<DateProvider>().selectedDate;
    final filtered = _buildFiltered(notes, schedules);

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Text('All Tasks', style: AppFonts.w700w24),
              ),
              SB.h16,
              _FilterChips(
                  selected: _filter,
                  onChanged: (f) => setState(() => _filter = f)),
              SB.h8,
              AppDividers.dark,
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child:
                            Text('Nothing here yet', style: AppFonts.w400g14))
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: filtered.length,
                        separatorBuilder: (context, _) => AppDividers.dark,
                        itemBuilder: (_, i) => _TaskTile(item: filtered[i]),
                      ),
              ),
            ],
          ),
          if (_fabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _fabOpen = false),
                child: Container(color: Colors.black.withAlpha(120)),
              ),
            ),
          Positioned(
            bottom: 24,
            right: 16,
            child: SpeedDialFAB(
              date: date,
              isOpen: _fabOpen,
              onToggle: () => setState(() => _fabOpen = !_fabOpen),
              onClose: () => setState(() => _fabOpen = false),
            ),
          ),
        ],
      ),
    );
  }

  List<_TaskItem> _buildFiltered(
      List<NoteModel> notes, List<ScheduleModel> schedules) {
    final items = <_TaskItem>[];

    if (_filter == _Filter.all || _filter == _Filter.notes) {
      items.addAll(notes
          .where((n) => n.type == NoteType.note)
          .map((n) => _TaskItem.fromNote(n)));
    }
    if (_filter == _Filter.all || _filter == _Filter.checklists) {
      items.addAll(notes
          .where((n) => n.type == NoteType.checklist)
          .map(_TaskItem.fromNote));
    }
    if (_filter == _Filter.all || _filter == _Filter.recipes) {
      items.addAll(notes
          .where((n) => n.type == NoteType.recipe)
          .map((n) => _TaskItem.fromNote(n)));
    }
    if (_filter == _Filter.all || _filter == _Filter.schedules) {
      items.addAll(schedules.map((s) => _TaskItem.fromSchedule(s)));
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }
}

class _TaskItem {
  final String id;
  final String title;
  final DateTime date;
  final bool isCompleted;
  final IconData icon;
  final Color iconColor;
  final NoteModel? note;
  final ScheduleModel? schedule;

  _TaskItem({
    required this.id,
    required this.title,
    required this.date,
    required this.isCompleted,
    required this.icon,
    required this.iconColor,
    this.note,
    this.schedule,
  });

  factory _TaskItem.fromNote(NoteModel n) {
    final icons = {
      NoteType.note: Icons.sticky_note_2_rounded,
      NoteType.checklist: Icons.checklist_rounded,
      NoteType.recipe: Icons.restaurant_menu_rounded,
    };
    return _TaskItem(
      id: n.id,
      title: n.title,
      date: n.date,
      isCompleted: n.isCompleted,
      icon: icons[n.type]!,
      iconColor: AppColors.orange,
      note: n,
    );
  }

  factory _TaskItem.fromSchedule(ScheduleModel s) {
    return _TaskItem(
      id: s.id,
      title: s.title,
      date: s.date,
      isCompleted: s.isCompleted,
      icon: Icons.event_rounded,
      iconColor: const Color(0xFF4A9EFF),
      schedule: s,
    );
  }
}

class _FilterChips extends StatelessWidget {
  final _Filter selected;
  final ValueChanged<_Filter> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = {
      _Filter.all: 'All',
      _Filter.notes: 'Notes',
      _Filter.checklists: 'Checklists',
      _Filter.recipes: 'Recipes',
      _Filter.schedules: 'Schedules',
    };
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.entries.map((e) {
          final isActive = selected == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.orange : context.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.orange : context.dividerC,
                  ),
                ),
                child: Text(
                  e.value,
                  style: (isActive ? AppFonts.w500w16 : AppFonts.w500g14)
                      .copyWith(fontSize: 13),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final _TaskItem item;
  const _TaskTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.iconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: item.iconColor, size: 20),
      ),
      title: Text(
        item.title,
        style: item.isCompleted ? AppFonts.w400w14Strike : AppFonts.w500w16,
      ),
      subtitle: Text(
        DateFormat('MMM d, yyyy').format(item.date),
        style: AppFonts.w400g12,
      ),
      trailing: Icon(
        item.isCompleted
            ? Icons.check_circle_rounded
            : Icons.circle_outlined,
        color: item.isCompleted ? AppColors.orange : AppColors.grey,
        size: 20,
      ),
      onTap: () {
        if (item.note != null) {
          context.read<DateProvider>().setDate(item.note!.date);
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => NoteDetailScreen(note: item.note!)));
        } else if (item.schedule != null) {
          context.read<DateProvider>().setDate(item.schedule!.date);
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) =>
                      ScheduleDetailScreen(schedule: item.schedule!)));
        }
      },
    );
  }
}
