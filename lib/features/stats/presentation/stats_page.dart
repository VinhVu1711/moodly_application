import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:moodlyy_application/features/mood/vm/mood_vm.dart';
import 'package:provider/provider.dart';

import 'package:moodlyy_application/features/stats/presentation/widgets/mood_bar_chart.dart';
import 'package:moodlyy_application/features/stats/presentation/widgets/mood_flow_chart.dart';
import 'package:moodlyy_application/features/stats/presentation/widgets/total_mood_tile.dart';

import '../vm/stats_vm.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

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
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final vm = context.read<StatsVM>();
              if (vm.scope == StatsScope.month) {
                // ✅ chỉ cho chọn THÁNG trong NĂM (không chọn ngày)
                final picked = await _pickMonth(context, vm.selectedMonth);
                if (picked != null) {
                  vm.setMonth(DateTime(picked.year, picked.month));
                }
              } else {
                // ✅ chỉ cho chọn NĂM
                final y = await _pickYear(context, vm.selectedYear);
                if (y != null) vm.setYear(y);
              }
            },
          ),
        ],
      ),
      body: const _StatsBody(),
    );
  }
}

class _StatsBody extends StatefulWidget {
  const _StatsBody();

  @override
  State<_StatsBody> createState() => _StatsBodyState();
}

class _StatsBodyState extends State<_StatsBody> {
  @override
  Widget build(BuildContext context) {
    final scope = context.select<StatsVM, StatsScope>((vm) => vm.scope);
    final month = context.select<StatsVM, DateTime>((vm) => vm.selectedMonth);
    final year = context.select<StatsVM, int>((vm) => vm.selectedYear);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mood = context.read<MoodVM>();
      if (scope == StatsScope.month) {
        mood.ensureMonthLoaded(month.year, month.month);
      } else {
        mood.ensureMonthLoaded(year, DateTime.now().month);
      }
    });

    return Selector<StatsVM, int>(
      selector: (_, vm) => vm.total,
      builder: (ctx, total, __) {
        if (total == 0) {
          return Center(
            child: Text(ctx.l10n.dont_have_data_title),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            // 🔥 Chip streak đặt ngay TRÊN MoodFlow
            _StreakChip(),
            SizedBox(height: 8),
            _Card(child: MoodFlowChart()),
            SizedBox(height: 12),
            _Card(child: MoodBarChart()),
            SizedBox(height: 12),
            _Card(child: TotalMoodTile()),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

/// 🔥 Chip streak — dùng Selector để rebuild tối thiểu
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

// ====== Helper chọn tháng nhanh (chỉ Month & Year, KHÔNG có Day) ======
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
                      (yy == currentMonth.year && m == currentMonth.month);
                  final label = _monthLabel(m);
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                      backgroundColor: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.10)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pop(ctx, DateTime(yy, m, 1)), // trả về y/m
                    child: Text(
                      label,
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

// ====== Helper chọn năm nhanh (giữ nguyên) ======
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
