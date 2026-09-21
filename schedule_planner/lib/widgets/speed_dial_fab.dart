import '../utils/common_imports.dart';
import '../models/note_model.dart';
import '../screens/add_note_screen.dart';
import '../screens/add_schedule_screen.dart';

class SpeedDialFAB extends StatelessWidget {
  final DateTime date;
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  const SpeedDialFAB({
    super.key,
    required this.date,
    required this.isOpen,
    required this.onToggle,
    required this.onClose,
  });

  void _navigate(BuildContext context, Widget screen) {
    onClose();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: isOpen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _DialItem(
                      icon: Icons.groups_rounded,
                      label: 'Schedule',
                      color: const Color(0xFF2196F3),
                      onTap: () => _navigate(
                          context, AddScheduleScreen(date: date)),
                    ),
                    SB.h8,
                    _DialItem(
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Recipe',
                      color: const Color(0xFF9B59B6),
                      onTap: () => _navigate(
                          context,
                          AddNoteScreen(
                              date: date, initialType: NoteType.recipe)),
                    ),
                    SB.h8,
                    _DialItem(
                      icon: Icons.checklist_rounded,
                      label: 'Checklist',
                      color: const Color(0xFF4CAF50),
                      onTap: () => _navigate(
                          context,
                          AddNoteScreen(
                              date: date, initialType: NoteType.checklist)),
                    ),
                    SB.h8,
                    _DialItem(
                      icon: Icons.sticky_note_2_rounded,
                      label: 'Note',
                      color: AppColors.orange,
                      onTap: () => _navigate(
                          context,
                          AddNoteScreen(
                              date: date, initialType: NoteType.note)),
                    ),
                    SB.h8,
                  ],
                )
              : const SizedBox.shrink(),
        ),
        FloatingActionButton(
          heroTag: 'speed_dial_main',
          backgroundColor: AppColors.orange,
          onPressed: onToggle,
          child: AnimatedRotation(
            turns: isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.add_rounded,
                color: AppColors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

class _DialItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(label, style: AppFonts.w400w14.copyWith(fontSize: 13)),
        ),
        SB.w8,
        FloatingActionButton.small(
          heroTag: label,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ],
    );
  }
}
