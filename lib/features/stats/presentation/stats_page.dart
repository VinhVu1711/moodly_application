import 'package:flutter/material.dart';
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
                final now = vm.selectedMonth;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                  helpText: 'Chọn ngày bất kỳ trong THÁNG muốn xem',
                );
                if (picked != null) {
                  vm.setMonth(DateTime(picked.year, picked.month));
                }
              } else {
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
    // Lấy snapshot các giá trị cần để ensure (tránh watch cả VM gây rebuild thừa)
    final scope = context.select<StatsVM, StatsScope>((vm) => vm.scope);
    final month = context.select<StatsVM, DateTime>((vm) => vm.selectedMonth);
    final year = context.select<StatsVM, int>((vm) => vm.selectedYear);

    // ✅ Ensure dữ liệu SAU frame hiện tại → tránh notifyListeners trong build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mood = context.read<MoodVM>();
      if (scope == StatsScope.month) {
        mood.ensureMonthLoaded(month.year, month.month);
      } else {
        // Tối thiểu đảm bảo có dữ liệu cho 1 tháng trong năm đã chọn
        mood.ensureMonthLoaded(year, DateTime.now().month);
        // (Sau này có thể preload đủ 12 tháng nếu muốn)
      }
    });

    return Selector<StatsVM, int>(
      selector: (_, vm) => vm.total,
      builder: (_, total, __) {
        if (total == 0) {
          return const Center(
            child: Text('Chưa có dữ liệu trong phạm vi đã chọn'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: const [
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
  const _Card({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

// ====== Helper chọn năm nhanh ======
Future<int?> _pickYear(BuildContext context, int currentYear) async {
  int temp = currentYear;
  return showDialog<int>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Chọn năm'),
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
