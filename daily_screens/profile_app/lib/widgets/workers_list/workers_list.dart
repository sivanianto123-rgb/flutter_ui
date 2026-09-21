import 'package:flutter/material.dart';
import 'package:profile_app/Screens/profile_screen.dart';
import 'package:profile_app/widgets/workers_list/workers_card.dart';

class WorkersList extends StatelessWidget {
  const WorkersList({super.key});

  @override
  Widget build(BuildContext context) {
    final workers = [
      {'image': 'lib/assets/images/profile.png', 'name': 'Tobi\nLateef'},
      {'image': 'lib/assets/images/profile.png', 'name': 'Queen\nNeedle'},
      {'image': 'lib/assets/images/profile.png', 'name': 'Joan\nBlessing'},
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: workers.length,
        itemBuilder: (context, index) {
          final worker = workers[index];

          return WorkersCard(
            imagePath: worker['image']!,
            name: worker['name']!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    imagePath: worker['image']!,
                    name: worker['name']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
