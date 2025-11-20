import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:moodlyy_application/features/mood/domain/mood.dart';
import 'package:moodlyy_application/features/mood/vm/mood_vm.dart';
import 'package:moodlyy_application/features/stats/share/stats_share_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import 'package:moodlyy_application/features/stats/presentation/widgets/mood_bar_chart.dart';
import 'package:moodlyy_application/features/stats/presentation/widgets/mood_flow_chart.dart';
import 'package:moodlyy_application/features/stats/presentation/widgets/total_mood_tile.dart';

import '../vm/stats_vm.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // SHARE CONTROLLERS — Được đưa lên đây
  final flowCtrl = ScreenshotController();
  final barCtrl = ScreenshotController();
  final totalCtrl = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Selector<StatsVM, StatsScope>(
          selector: (_, vm) => vm.scope,
          builder: (_, scope, __) {
            return SegmentedButton<StatsScope>(
              segments: const [
                ButtonSegment(value: StatsScope.month, label: Text('Tháng')),
                ButtonSegment(value: StatsScope.year, label: Text('Năm')),
              ],
              selected: {scope},
              onSelectionChanged: (s) =>
                  context.read<StatsVM>().setScope(s.first),
            );
          },
        ),
        actions: [
          const _PickDateButton(),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _onSharePressed,
          ),
        ],
      ),
      body: _StatsBody(
        flowCtrl: flowCtrl,
        barCtrl: barCtrl,
        totalCtrl: totalCtrl,
      ),
    );
  }

  // ----------------------------------------------------------------------
  // SHARE HANDLER
  // ----------------------------------------------------------------------

  Future<void> _onSharePressed() async {
    final vm = context.read<StatsVM>();

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đang chuẩn bị chia sẻ..."),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 1. Load data
      if (vm.scope == StatsScope.month) {
        await context.read<MoodVM>().ensureMonthLoaded(
          vm.selectedMonth.year,
          vm.selectedMonth.month,
        );
      } else {
        await context.read<MoodVM>().fetchYear(vm.selectedYear);
      }

      // 2. Wait for data to propagate through the widget tree
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Force rebuild if needed
      if (mounted) setState(() {});

      // 4. Wait for multiple frames to ensure everything is painted
      for (int i = 0; i < 3; i++) {
        await WidgetsBinding.instance.endOfFrame;
      }

      // 5. Additional safety delay
      await Future.delayed(const Duration(milliseconds: 500));

      // 6. Capture with error handling
      Uint8List? flowImg, barImg, totalImg;

      flowImg = await flowCtrl.capture();
      if (flowImg == null) throw Exception("Failed to capture flow chart");

      barImg = await barCtrl.capture();
      if (barImg == null) throw Exception("Failed to capture bar chart");

      totalImg = await totalCtrl.capture();
      if (totalImg == null) throw Exception("Failed to capture total tile");

      // 7. Calculate summary
      final dominantMoodEntry = vm.percents.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );

      final summary =
          """
Mood Summary (${vm.isYearMode ? vm.selectedYear : "${vm.selectedMonth.month}/${vm.selectedMonth.year}"})
- Total logged days: ${vm.total}
- Streak: ${vm.currentStreak} days
- Dominant mood: ${dominantMoodEntry.key.label}
"""
              .trim();

      // 8. Share
      final service = StatsShareService();
      await service.shareStats(
        flow: flowImg,
        bar: barImg,
        total: totalImg,
        textSummary: summary,
      );
    } catch (e) {
      debugPrint("Share error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không thể chia sẻ: ${e.toString()}"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// ----------------------------------------------------------------------
// BUTTON PICK DATE
// ----------------------------------------------------------------------

class _PickDateButton extends StatelessWidget {
  const _PickDateButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.date_range),
      onPressed: () async {
        final vm = context.read<StatsVM>();
        if (vm.scope == StatsScope.month) {
          final picked = await _pickMonth(context, vm.selectedMonth);
          if (picked != null) {
            vm.setMonth(DateTime(picked.year, picked.month));
          }
        } else {
          final y = await _pickYear(context, vm.selectedYear);
          if (y != null) vm.setYear(y);
        }
      },
    );
  }
}

// ----------------------------------------------------------------------
// BODY
// ----------------------------------------------------------------------

class _StatsBody extends StatefulWidget {
  final ScreenshotController flowCtrl;
  final ScreenshotController barCtrl;
  final ScreenshotController totalCtrl;

  const _StatsBody({
    required this.flowCtrl,
    required this.barCtrl,
    required this.totalCtrl,
    super.key,
  });

  @override
  State<_StatsBody> createState() => _StatsBodyState();
}

class _StatsBodyState extends State<_StatsBody> {
  @override
  Widget build(BuildContext context) {
    final scope = context.select<StatsVM, StatsScope>((vm) => vm.scope);
    final month = context.select<StatsVM, DateTime>((vm) => vm.selectedMonth);
    final year = context.select<StatsVM, int>((vm) => vm.selectedYear);

    // LOAD DATA AFTER BUILD
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final mood = context.read<MoodVM>();

      if (scope == StatsScope.month) {
        await mood.ensureMonthLoaded(month.year, month.month);
      } else {
        await mood.fetchYear(year);
      }
    });

    return Selector<StatsVM, int>(
      selector: (_, vm) => vm.total,
      builder: (ctx, total, __) {
        if (total == 0) {
          return Center(child: Text(ctx.l10n.dont_have_data_title));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _StreakChip(),
              const SizedBox(height: 8),

              // FLOW CHART
              _Card(
                child: Screenshot(
                  controller: widget.flowCtrl,
                  child: const MoodFlowChart(),
                ),
              ),
              const SizedBox(height: 12),

              // BAR CHART
              _Card(
                child: Screenshot(
                  controller: widget.barCtrl,
                  child: const MoodBarChart(),
                ),
              ),
              const SizedBox(height: 12),

              // TOTAL TILE
              _Card(
                child: Screenshot(
                  controller: widget.totalCtrl,
                  child: const TotalMoodTile(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// CARD
// ----------------------------------------------------------------------

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ----------------------------------------------------------------------
// STREAK CHIP
// ----------------------------------------------------------------------

class _StreakChip extends StatelessWidget {
  const _StreakChip();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Selector<StatsVM, int>(
        selector: (_, vm) => vm.currentStreak,
        builder: (context, streak, __) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.days_count(streak),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------
// PICK MONTH
// ----------------------------------------------------------------------

Future<DateTime?> _pickMonth(
  BuildContext context,
  DateTime currentMonth,
) async {
  int yy = currentMonth.year;
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 10, 0),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            title: Row(
              children: [
                IconButton(
                  tooltip: 'Năm trước',
                  onPressed: () => setState(() => yy--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$yy',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Năm sau',
                  onPressed: () => setState(() => yy++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            content: SizedBox(
              width: 320,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                children: List.generate(12, (i) {
                  final m = i + 1;
                  final isSelected =
                      yy == currentMonth.year && m == currentMonth.month;
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1)
                          : null,
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, DateTime(yy, m, 1)),
                    child: Text(
                      _monthLabel(m),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      );
    },
  );
}

String _monthLabel(int m) => const [
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
][m - 1];

// ----------------------------------------------------------------------
// PICK YEAR
// ----------------------------------------------------------------------

Future<int?> _pickYear(BuildContext context, int currentYear) async {
  int temp = currentYear;
  return showDialog<int>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(ctx.l10n.pick_year_title),
        content: SizedBox(
          height: 200,
          width: 300,
          child: YearPicker(
            firstDate: DateTime(currentYear - 5),
            lastDate: DateTime(currentYear + 5),
            selectedDate: DateTime(temp),
            onChanged: (d) {
              temp = d.year;
              Navigator.pop(ctx, temp);
            },
          ),
        ),
      );
    },
  );
}
