import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../utils/common_imports.dart';
import '../../providers/note_provider.dart';
import '../../providers/date_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/note_card.dart';
import '../add_note_screen.dart';
import '../note_detail_screen.dart';

class HomeNotesSection extends StatelessWidget {
  const HomeNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final date = context.watch<DateProvider>().selectedDate;
    final notes = context.watch<NoteProvider>().forDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SB.h20,
        SectionHeader(
          title: 'Notes & Tasks',
          actionLabel: '+ Add',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddNoteScreen(date: date),
            ),
          ),
        ),
        SB.h12,
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('No notes for this day', style: AppFonts.w400g14),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (_, i) => NoteCard(
                note: notes[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteDetailScreen(note: notes[i]),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
