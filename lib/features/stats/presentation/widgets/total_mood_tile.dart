import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vm/stats_vm.dart';

class TotalMoodTile extends StatelessWidget {
  const TotalMoodTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<StatsVM, int>(
      selector: (_, vm) => vm.total,
      builder: (_, total, __) {
        return Row(
          children: [
            const Icon(Icons.summarize),
            const SizedBox(width: 12),
            Text('TotalMood: $total ngày có mood'),
          ],
        );
      },
    );
  }
}
