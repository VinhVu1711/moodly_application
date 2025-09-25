import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../vm/stats_vm.dart';

class MoodFlowChart extends StatelessWidget {
  const MoodFlowChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<StatsVM, List<MoodPoint>>(
      selector: (_, vm) => vm.moodFlow,
      builder: (_, points, __) {
        final spots = <FlSpot>[];
        for (final p in points) {
          if (p.y != null) spots.add(FlSpot(p.x.toDouble(), p.y!));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MoodFlow',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: -2,
                  maxY: 2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 1),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: (points.length <= 12) ? 1 : 5,
                        getTitlesWidget: (v, _) => Text(v.toInt().toString()),
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
}
