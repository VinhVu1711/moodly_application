import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../vm/stats_vm.dart';
import '../../../mood/domain/mood.dart'; // đường dẫn của em tới Emotion5

class MoodBarChart extends StatelessWidget {
  const MoodBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<StatsVM, Map<Emotion5, double>>(
      selector: (_, vm) => vm.percents,
      builder: (_, percents, __) {
        final entries = Emotion5.values
            .map((e) => MapEntry(e, percents[e]!))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MoodBar (%)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  minY: 0, // ADD: rõ ràng
                  maxY: 100, // ADD
                  barGroups: [
                    for (int i = 0; i < entries.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: entries[i].value, width: 16),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // ADD
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // ADD
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 20),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final emo = Emotion5.values[v.toInt()];
                          return Text(_short(emo));
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _short(Emotion5 e) => switch (e) {
    Emotion5.verySad => 'V.Sad',
    Emotion5.sad => 'Sad',
    Emotion5.neutral => 'Neutral',
    Emotion5.happy => 'Happy',
    Emotion5.veryHappy => 'V.Happy',
  };
}
