import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:moodlyy_application/features/mood/presentation/mood_l10n.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:moodlyy_application/features/stats/vm/stats_vm.dart';
import 'package:moodlyy_application/features/mood/domain/mood.dart';

class MoodFlowChart extends StatelessWidget {
  const MoodFlowChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<StatsVM, List<MoodPoint>>(
      selector: (_, vm) => vm.moodFlow,
      builder: (context, points, __) {
        final spots = <FlSpot>[];
        for (final p in points) {
          if (p.y != null) spots.add(FlSpot(p.x.toDouble(), p.y!));
        }

        final month = context.select<StatsVM, DateTime>(
          (vm) => vm.selectedMonth,
        );
        final isYearMode = context.select<StatsVM, bool>((vm) => vm.isYearMode);
        final xCount = context.select<StatsVM, int>((vm) => vm.xCount);

        // NEW: số ngày đã react / số tháng full react
        final reactedDays = context.select<StatsVM, int>(
          (vm) => vm.reactedDaysInSelectedMonth,
        );
        final fullMonths = context.select<StatsVM, int>(
          (vm) => vm.fullyReactedMonthsInSelectedYear,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.show_chart_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.mood_flow_title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Text(
                        //   // Giữ nguyên text gốc (UI/logic không đổi)
                        //   'Your emotional journey this year', // sẽ thay đổi bên dưới theo isYearMode
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     color: Color(0xFF757575),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chip hiển thị số ngày/tháng đã react
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isYearMode
                          ? context.l10n.months_count(fullMonths)
                          : context.l10n.days_count(reactedDays),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              // Ghi chú phụ (month/year) – giữ nguyên logic & UI
              const SizedBox(height: 4),
              Builder(
                builder: (ctx) {
                  return Text(
                    isYearMode
                        ? ctx.l10n.mood_flow_year_title
                        : ctx.l10n.mood_flow_month_title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Flexible(flex: 0, child: _CompactMoodLegend()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 210,
                      child: LineChart(
                        LineChartData(
                          minY: -2,
                          maxY: 2,
                          minX: 1,
                          maxX: xCount.toDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  final emotion = _getEmotionFromValue(spot.y);
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: emotion.color,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.2),
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  final emotion = _getEmotionFromValue(value);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: emotion.color.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: emotion.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: isYearMode ? 28 : 44,
                                getTitlesWidget: (value, _) {
                                  if (isYearMode) {
                                    final monthIndex = value.toInt();
                                    if (monthIndex < 1 || monthIndex > 12) {
                                      return const SizedBox.shrink();
                                    }
                                    final show =
                                        monthIndex == 1 || monthIndex % 3 == 1;
                                    if (!show) return const SizedBox.shrink();

                                    final monthNames = [
                                      '',
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec',
                                    ];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        monthNames[monthIndex],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  } else {
                                    final day = value.toInt();
                                    final lastDay = DateTime(
                                      month.year,
                                      month.month + 1,
                                      0,
                                    ).day;
                                    final show =
                                        day == 1 ||
                                        day % 5 == 1 ||
                                        day == lastDay;
                                    if (!show) return const SizedBox.shrink();

                                    final date = DateTime(
                                      month.year,
                                      month.month,
                                      day,
                                    );
                                    const weekdayNames = [
                                      '',
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$day',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            weekdayNames[date.weekday],
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                            horizontalInterval: 1,
                            verticalInterval: isYearMode ? 1 : 5,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 0.5,
                              dashArray: const [3, 3],
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.1),
                              strokeWidth: 0.5,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final emotion = _getEmotionFromValue(spot.y);
                                  if (isYearMode) {
                                    final monthNames = [
                                      '',
                                      'January',
                                      'February',
                                      'March',
                                      'April',
                                      'May',
                                      'June',
                                      'July',
                                      'August',
                                      'September',
                                      'October',
                                      'November',
                                      'December',
                                    ];
                                    final monthIndex = spot.x.toInt();
                                    return LineTooltipItem(
                                      '${monthNames[monthIndex]}\n${emotion.label}', // dùng label từ model
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  } else {
                                    final day = spot.x.toInt();
                                    return LineTooltipItem(
                                      'Day $day\n${emotion.label}', // dùng label từ model
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  }
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Emotion5 _getEmotionFromValue(double value) {
    if (value >= 1.5) return Emotion5.veryHappy;
    if (value >= 0.5) return Emotion5.happy;
    if (value >= -0.5) return Emotion5.neutral;
    if (value >= -1.5) return Emotion5.sad;
    return Emotion5.verySad;
  }
}

// Compact legend to fix overflow issue
class _CompactMoodLegend extends StatelessWidget {
  const _CompactMoodLegend();

  @override
  Widget build(BuildContext context) {
    final items = Emotion5.values; // dùng enum trực tiếp

    return Container(
      width: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.mood_flow_emotions_title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          for (final emotion in items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: emotion.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: emotion.color.withOpacity(0.3),
                          blurRadius: 2,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      emotion.l10n(context), // tái dùng label từ model
                      style: const TextStyle(fontSize: 9),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
