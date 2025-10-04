import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:moodlyy_application/features/mood/presentation/mood_l10n.dart';
import 'package:provider/provider.dart';
import '../../mood/domain/mood.dart';
import '../../mood/vm/mood_vm.dart';
import '../../calendar/vm/calendar_vm.dart'; // ⬅️ dùng helper kiểm tra ngày tương lai

class MoodEditPage extends StatefulWidget {
  final DateTime day;
  const MoodEditPage({super.key, required this.day});

  @override
  State<MoodEditPage> createState() => _MoodEditPageState();
}

class _MoodEditPageState extends State<MoodEditPage> {
  static const List<Emotion5> orderedEmotions = [
    Emotion5.veryHappy,
    Emotion5.happy,
    Emotion5.neutral,
    Emotion5.sad,
    Emotion5.verySad,
  ];

  late DateTime _day;

  Emotion5 _mainEmotion = Emotion5.neutral;
  final Set<AnotherEmotion> _subs = {};
  final Set<People> _people = {};
  final TextEditingController _noteCtrl = TextEditingController();

  bool _openEmotions = true;
  bool _openPeople = true;

  @override
  void initState() {
    super.initState();
    _day = DateTime(widget.day.year, widget.day.month, widget.day.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateFromVM(_day);
    });
  }

  void _hydrateFromVM(DateTime day) {
    final vm = context.read<MoodVM>();
    final existing = vm.moodOf(day);
    if (existing != null) {
      setState(() {
        _mainEmotion = existing.emotion;
        _subs
          ..clear()
          ..addAll(existing.another);
        _people
          ..clear()
          ..addAll(existing.people);
        _noteCtrl.text = existing.note ?? '';
      });
    } else {
      setState(() {
        _mainEmotion = Emotion5.neutral;
        _subs.clear();
        _people.clear();
        _noteCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatLongDate(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
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
    final wd = weekdays[d.weekday - 1];
    final mo = months[d.month - 1];
    return '$wd, $mo ${d.day}';
  }

  String _monthName(int m) {
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

  // ⬇️ helper hiển thị cảnh báo ngày tương lai
  void _showFutureNotAllowed(String message) {
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

  Future<void> _pickDayInMonth() async {
    final cal = context.read<CalendarVM>();

    // Giới hạn chọn trong cùng tháng với _day hiện tại
    final monthStart = DateTime(_day.year, _day.month, 1);
    final monthEnd = DateTime(_day.year, _day.month + 1, 0);

    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: monthStart,
      lastDate: monthEnd,
      helpText: 'Select a day in ${_monthName(_day.month)} ${_day.year}',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(
              ctx,
            ).colorScheme.copyWith(primary: Theme.of(ctx).colorScheme.primary),
          ),
          child: child!,
        );
      },
      // ✅ chặn chọn ngày tương lai ngay trong date picker
      selectableDayPredicate: (d) =>
          d.month == _day.month &&
          d.year == _day.year &&
          cal.isSelectableDay(d),
    );
    if (!mounted) return;
    if (picked != null) {
      // ✅ kiểm tra lại sau khi chọn (phòng trường hợp predicate thay đổi)
      final err = cal.canReactOn(picked, context);
      if (err != null) {
        _showFutureNotAllowed(err);
        return;
      }
      setState(() {
        _day = DateTime(picked.year, picked.month, picked.day);
      });
      _hydrateFromVM(_day);
    }
  }

  Future<void> _confirmAndDelete() async {
    final vm = context.read<MoodVM>();
    final cs = Theme.of(context).colorScheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(ctx.l10n.delete_title),
        content: Text(
          ctx.l10n.delete_content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ctx.l10n.cancel_button_title),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(ctx.l10n.delete_button_title),
          ),
        ],
      ),
    );

    if (ok == true) {
      final err = await vm.deleteDay(_day);
      if (!mounted) return;
      if (err == null) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MoodVM>();
    final hasExistingMood = context.select<MoodVM, bool>(
      (m) => m.moodOf(_day) != null,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        centerTitle: true,
        // 👇 Bấm title để chọn ngày trong tháng (đã chặn future)
        title: InkWell(
          onTap: _pickDayInMonth,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatLongDate(_day),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 18),
            ],
          ),
        ),
        actions: [
          if (hasExistingMood)
            IconButton(
              tooltip: 'Delete mood',
              icon: const Icon(Icons.delete_outline),
              onPressed: vm.isBusy ? null : _confirmAndDelete,
            ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: vm.isBusy
                ? null
                : () async {
                    // ✅ vẫn kiểm tra lần cuối trước khi lưu
                    final err = context.read<CalendarVM>().canReactOn(
                      _day,
                      context,
                    );
                    if (err != null) {
                      _showFutureNotAllowed(err);
                      return;
                    }

                    final res = await context.read<MoodVM>().upsertDay(
                      day: _day,
                      emotion: _mainEmotion,
                      another: _subs.toList(),
                      people: _people.toList(),
                      note: _noteCtrl.text.trim().isEmpty
                          ? null
                          : _noteCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    if (res == null) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(res)));
                    }
                  },
            child: Text(
              vm.isBusy ? context.l10n.saving_status : context.l10n.done_status,
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _Card(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.how_was_your_day,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: orderedEmotions.map((e) {
                    final selected = _mainEmotion == e;
                    return _MainEmotionIcon(
                      emotion: e,
                      selected: selected,
                      onTap: () => setState(() => _mainEmotion = e),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ExpansionSection(
            title: context.l10n.emotions_title,
            initiallyExpanded: _openEmotions,
            onExpansionChanged: (v) => setState(() => _openEmotions = v),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: _IconGrid<AnotherEmotion>(
                items: AnotherEmotion.values,
                isSelected: (a) => _subs.contains(a),
                onToggle: (a) => setState(() {
                  _subs.contains(a) ? _subs.remove(a) : _subs.add(a);
                }),
                labelOf: (a) => a.l10n(context),
                assetOf: (a) => a.assetPath,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ExpansionSection(
            // ✅ sửa: tiêu đề People đúng thay vì bị "Emotions"
            title: context
                .l10n
                .people_title, // nếu bạn có key i18n, đổi thành: context.l10n.people_title
            initiallyExpanded: _openPeople,
            onExpansionChanged: (v) => setState(() => _openPeople = v),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: _IconGrid<People>(
                items: People.values,
                isSelected: (p) => _people.contains(p),
                onToggle: (p) => setState(() {
                  _people.contains(p) ? _people.remove(p) : _people.add(p);
                }),
                labelOf: (p) => p.l10n(context),
                assetOf: (p) => p.assetPath,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _noteCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: context.l10n.add_a_note_title,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _Card({required this.child, this.padding});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: padding,
      child: child,
    );
  }
}

class _MainEmotionIcon extends StatelessWidget {
  final Emotion5 emotion;
  final bool selected;
  final VoidCallback onTap;

  const _MainEmotionIcon({
    required this.emotion,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? emotion.color
        : Theme.of(context).colorScheme.surfaceContainerHigh;
    final size = selected ? 62.0 : 56.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: size,
            height: size,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            padding: const EdgeInsets.all(10),
            child: Image.asset(emotion.assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 6),
          Text(
            // ✅ dùng i18n thay vì label cứng
            emotion.l10n(context),
            style: TextStyle(
              fontSize: 12,
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpansionSection extends StatelessWidget {
  final String title;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final Widget child;

  const _ExpansionSection({
    required this.title,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          // ✅ dùng title truyền vào, không hardcode
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _IconGrid<T> extends StatelessWidget {
  final List<T> items;
  final bool Function(T) isSelected;
  final void Function(T) onToggle;
  final String Function(T) labelOf;
  final String Function(T) assetOf;

  const _IconGrid({
    required this.items,
    required this.isSelected,
    required this.onToggle,
    required this.labelOf,
    required this.assetOf,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 14,
      children: items.map((it) {
        final selected = isSelected(it);
        return InkWell(
          onTap: () => onToggle(it),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(assetOf(it), fit: BoxFit.contain),
                ),
                const SizedBox(height: 6),
                Text(
                  labelOf(it),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
