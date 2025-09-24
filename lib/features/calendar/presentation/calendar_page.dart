import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';

import '../../mood/domain/mood.dart';
import '../../mood/vm/mood_vm.dart';
import '../data/quote_service.dart';
import '../vm/calendar_vm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Ô ngày: chỉ viền cho "hôm nay", icon cảm xúc nếu có mood (không tô nền)
  Widget _dayCellWithEmotion({
    required BuildContext context,
    required DateTime day,
    required bool isToday,
    required Emotion5? emotion,
    required Color mint,
  }) {
    final cs = Theme.of(context).colorScheme;
    const double circleSize = 42;
    final hasMood = emotion != null;

    final circle = Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: isToday ? mint : cs.onSurface.withOpacity(0.15),
          width: isToday ? 2.5 : 1.5,
        ),
      ),
      child: hasMood
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(emotion.assetPath, fit: BoxFit.contain),
            )
          : null,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 3),
        Text(
          '${day.day}',
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.7),
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // nạp lịch + mood tháng hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cal = context.read<CalendarVM>();
      final now = DateTime.now();
      cal.init();
      context.read<MoodVM>().fetchMonth(now.year, now.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.watch<MoodVM>();
    final cal = context.watch<CalendarVM>();
    final cs = Theme.of(context).colorScheme;
    final mint = cal.mint;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isLoading = mood.isLoadingMonth; // 👈 NEW

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: cal.highlightEnabled
              ? 'Tắt highlight ngày có mood'
              : 'Bật highlight ngày có mood',
          icon: Icon(
            cal.highlightEnabled
                ? Icons.brightness_5
                : Icons.brightness_5_outlined,
          ),
          onPressed: cal.toggleHighlight,
        ),
        // Bấm title để chọn tháng/năm
        title: InkWell(
          onTap: _pickMonthYear,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_monthName(cal.focusedMonth.month)} ${cal.focusedMonth.year}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 18),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Quote hôm nay',
            icon: const Icon(Icons.cookie),
            onPressed: () async {
              final qs = QuoteService(Supabase.instance.client);
              final canShow = await qs.shouldShowTodayQuote();
              final quote = await qs.getTodayQuote(lang: 'vi');
              if (canShow && mounted) {
                await showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Inspiration for today',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(quote, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(backgroundColor: mint),
                          child: const Text('Nice!'),
                        ),
                      ],
                    ),
                  ),
                );
                await qs.markShown();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bạn đã xem quote hôm nay rồi!'),
                  ),
                );
              }
            },
          ),
        ],
      ),

      // 👇 NEW: Overlay loading + chặn thao tác khi đang load tháng
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading, // chặn swipe/chạm khi đang tải
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: cal.focusedMonth,
                currentDay: today,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerVisible: false,
                availableGestures: AvailableGestures.horizontalSwipe,
                rowHeight: 65,

                onPageChanged: (newFocused) {
                  cal.loadMonth(newFocused);
                  context.read<MoodVM>().fetchMonth(
                    newFocused.year,
                    newFocused.month,
                  );
                },

                selectedDayPredicate: (_) => false,

                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                  weekendTextStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                  outsideTextStyle: const TextStyle(color: Colors.transparent),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  weekendStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (ctx, day, _) {
                    final m = mood.moodOf(day);
                    final show = cal.highlightEnabled && !isLoading; // 👈 NEW
                    return _dayCellWithEmotion(
                      context: context,
                      day: day,
                      isToday: _isSameDay(day, today),
                      emotion: show ? m?.emotion : null,
                      mint: mint,
                    );
                  },
                  todayBuilder: (ctx, day, _) {
                    final m = mood.moodOf(day);
                    final show = cal.highlightEnabled && !isLoading; // 👈 NEW
                    return _dayCellWithEmotion(
                      context: context,
                      day: day,
                      isToday: true,
                      emotion: show ? m?.emotion : null,
                      mint: mint,
                    );
                  },
                  outsideBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),

                onDaySelected: (selected, _) async {
                  final changed = await context.push(
                    '/mood/new',
                    extra: selected,
                  );
                  if (changed == true) {
                    await context.read<MoodVM>().fetchMonth(
                      cal.focusedMonth.year,
                      cal.focusedMonth.month,
                    );
                  }
                },
              ),
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: cs.surface.withOpacity(0.6),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // ==== Month-Year Picker (không cần package) ====
  Future<void> _pickMonthYear() async {
    final cal = context.read<CalendarVM>();
    final mood = context.read<MoodVM>();
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _MonthYearDialog(initial: cal.focusedMonth),
    );
    if (selected != null) {
      final focused = DateTime(selected.year, selected.month, 1);
      await cal.loadMonth(focused);
      await mood.fetchMonth(focused.year, focused.month);
      setState(() {}); // rebuild tiêu đề
    }
  }

  String _monthName(int m) {
    const names = [
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
    return names[m - 1];
  }
}

// ----------------- Month-Year Dialog -----------------
class _MonthYearDialog extends StatefulWidget {
  final DateTime initial;
  const _MonthYearDialog({required this.initial});

  @override
  State<_MonthYearDialog> createState() => _MonthYearDialogState();
}

class _MonthYearDialogState extends State<_MonthYearDialog> {
  late int _year;
  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final months = List.generate(12, (i) => i + 1);

    return Dialog(
      backgroundColor: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: chọn năm
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous year',
                  onPressed: () => setState(() => _year--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_year',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next year',
                  onPressed: () => setState(() => _year++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Grid tháng
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: months.map((m) {
                final monthName = _monthNameLong(m);
                final isInitial =
                    _year == widget.initial.year && m == widget.initial.month;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final selected = DateTime(_year, m, 1);
                    Navigator.pop(context, selected);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isInitial
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 8,
                    ),
                    child: Text(
                      monthName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isInitial
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isInitial
                            ? cs.onPrimaryContainer
                            : cs.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthNameLong(int m) {
    const names = [
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
    return names[m - 1];
  }
}
