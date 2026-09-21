import 'package:flutter/material.dart';
import 'package:watch_app/widgets/collections/collection_types.dart';
import 'package:watch_app/widgets/collections/collections_list/collections_list.dart';

import '../../styles/fonts/fonts.dart';

class Collections extends StatelessWidget {
  const Collections({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text('Collections', style: AppFonts.w500b21)],
        ),
        SizedBox(height: 12),
        CollectionTypes(),
        SizedBox(height: 20),
        CollectionsList(),
      ],
    );
  }
}
