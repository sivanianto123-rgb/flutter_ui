import '../utils/common_imports.dart';
import '../providers/date_provider.dart';
import 'sections/home_header.dart';
import 'sections/home_timeline_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<DateProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(),
            HomeTimelineSection(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
