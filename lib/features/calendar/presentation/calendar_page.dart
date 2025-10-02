import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
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
  Future<void> _showTodayQuoteDialog(BuildContext context) async {
    final qs = QuoteService(Supabase.instance.client);
    final cs = Theme.of(context).colorScheme;
    // final t = AppLocalizations.of(context)!;

    final quote = await qs.getTodayQuote(lang: 'vi');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        title: Text(
          ctx.l10n.quote_label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          quote,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close_button_title),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    await qs.markShown();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Ô ngày: viền nhẹ cho ngày thường, viền màu mint cho hôm nay; có icon nếu đã react.
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

    final isLoading = mood.isLoadingMonth;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: cal.isFiltered
              ? 'Đang lọc: ${cal.filterEmotion!.label}. Bấm để đổi/clear'
              : 'Lọc theo cảm xúc',
          icon: Icon(
            cal.isFiltered ? Icons.filter_alt : Icons.filter_alt_outlined,
          ),
          onPressed: _pickEmotionFilter,
        ),
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
          IconButton(
            tooltip: 'Quote hôm nay',
            icon: const Icon(Icons.cookie),
            onPressed: () async {
              _showTodayQuoteDialog(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
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
                  outsideDaysVisible:
                      false, // ⬅️ Ẩn hoàn toàn ngày của tháng trước/sau
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
                    final matchesFilter = cal.filterEmotion == null
                        ? true
                        : (m?.emotion == cal.filterEmotion);
                    final show =
                        cal.highlightEnabled && !isLoading && matchesFilter;

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
                    final matchesFilter = cal.filterEmotion == null
                        ? true
                        : (m?.emotion == cal.filterEmotion);
                    final show =
                        cal.highlightEnabled && !isLoading && matchesFilter;

                    return _dayCellWithEmotion(
                      context: context,
                      day: day,
                      isToday: true,
                      emotion: show ? m?.emotion : null,
                      mint: mint,
                    );
                  },
                  // Giữ ẩn ô ngoài tháng
                  outsideBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),

                onDaySelected: (selected, _) async {
                  // ⬅️ Chỉ chặn bằng dialog, không ẩn UI
                  final err = context.read<CalendarVM>().canReactOn(selected);
                  if (err != null) {
                    _showFutureNotAllowed(context, err);
                    return;
                  }

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

  // Dialog chọn cảm xúc
  Future<void> _pickEmotionFilter() async {
    final cal = context.read<CalendarVM>();
    final cs = Theme.of(context).colorScheme;

    final selected = await showDialog<Emotion5?>(
      context: context,
      builder: (ctx) {
        Emotion5? temp = cal.filterEmotion;
        return AlertDialog(
          backgroundColor: cs.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            ctx.l10n.sort_by_emotion_title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          content: StatefulBuilder(
            builder: (ctx, setStateSB) {
              Widget chip({
                required Widget child,
                required bool selected,
                required VoidCallback onTap,
              }) {
                return InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: child,
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chip(
                    selected: temp == null,
                    onTap: () => setStateSB(() => temp = null),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.all_inclusive, size: 18),
                        SizedBox(width: 8),
                        Text('All'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: Emotion5.values.map((e) {
                      final sel = temp == e;
                      return chip(
                        selected: sel,
                        onTap: () => setStateSB(() => temp = e),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Image.asset(
                                e.assetPath,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(e.label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel_button_title),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, temp),
              child: Text(context.l10n.apply_button_title),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await cal.setFilterEmotion(selected);
  }

  void _showFutureNotAllowed(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Không thể thực hiện'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                  child: Text(context.l10n.cancel_button_title),
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
