import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../mood/domain/mood.dart'; // <-- chứa Emotion5
import '../../mood/vm/mood_vm.dart'; // <-- VM hiện có của em, để lấy dữ liệu

/// Phạm vi thống kê
enum StatsScope { month, year }

/// Điểm số quy đổi cho đường MoodFlow
extension Emotion5Score on Emotion5 {
  int get score => switch (this) {
    Emotion5.verySad => -2,
    Emotion5.sad => -1,
    Emotion5.neutral => 0,
    Emotion5.happy => 1,
    Emotion5.veryHappy => 2,
  };
}

/// Model điểm trên biểu đồ
class MoodPoint {
  final int x; // ngày trong tháng (1..31) hoặc tháng trong năm (1..12)
  final double? y; // có thể null (ngày không có mood)
  MoodPoint(this.x, this.y);
}

class StatsVM extends ChangeNotifier {
  StatsVM();

  // ------ state được điều khiển từ UI ------
  StatsScope _scope = StatsScope.month;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedYear = DateTime.now().year;

  StatsScope get scope => _scope;
  DateTime get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  // ✅ tiện cho UI hỏi nhanh chế độ hiện tại
  bool get isYearMode => _scope == StatsScope.year;
  bool get isMonthMode => _scope == StatsScope.month;

  /// ✅ tổng số tick trục X (năm: 12 tháng; tháng: số ngày trong tháng)
  int get xCount => isYearMode
      ? 12
      : DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);

  // ------ nguồn dữ liệu (được bơm từ DI) ------
  MoodVM? _moodVM;

  // ADD: callback dùng cho add/removeListener
  void _onMoodChanged() => notifyListeners();

  void bindMoodVM(MoodVM vm) {
    if (!identical(_moodVM, vm)) {
      _moodVM?.removeListener(_onMoodChanged);
      _moodVM = vm;
      _moodVM?.addListener(_onMoodChanged);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _moodVM?.removeListener(_onMoodChanged);
    super.dispose();
  }

  // ------ hành động từ UI ------
  void setScope(StatsScope s) {
    if (_scope != s) {
      _scope = s;
      notifyListeners();
    }
  }

  void setMonth(DateTime m) {
    final onlyMonth = DateTime(m.year, m.month);
    if (_selectedMonth.year != onlyMonth.year ||
        _selectedMonth.month != onlyMonth.month) {
      _selectedMonth = onlyMonth;
      notifyListeners();
    }
  }

  void setYear(int y) {
    if (_selectedYear != y) {
      _selectedYear = y;
      notifyListeners();
    }
  }

  // ------ truy xuất dữ liệu thô từ MoodVM ------
  Map<DateTime, Emotion5> get _mainByDay {
    final vm = _moodVM;
    if (vm == null) return const {};
    return vm.mainEmotionByDay; // map theo ngày 00:00
  }

  // ------ tính toán dẫn xuất cho từng scope ------
  List<MoodPoint> get moodFlow {
    if (_scope == StatsScope.month) {
      final daysInMonth = DateUtils.getDaysInMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      return List.generate(daysInMonth, (i) {
        final day = DateTime(_selectedMonth.year, _selectedMonth.month, i + 1);
        final emo = _mainByDay[day];
        return MoodPoint(i + 1, emo?.score.toDouble());
      });
    } else {
      return List.generate(12, (i) {
        final m = i + 1;
        final start = DateTime(_selectedYear, m, 1);
        final end = DateTime(
          _selectedYear,
          m + 1,
          1,
        ).subtract(const Duration(days: 1));
        final entries = _mainByDay.entries.where(
          (e) => !e.key.isBefore(start) && !e.key.isAfter(end),
        );
        if (entries.isEmpty) return MoodPoint(m, null);
        final avg = entries.map((e) => e.value.score).average;
        return MoodPoint(m, avg);
      });
    }
  }

  Map<Emotion5, int> get counts {
    final Map<Emotion5, int> c = {
      Emotion5.verySad: 0,
      Emotion5.sad: 0,
      Emotion5.neutral: 0,
      Emotion5.happy: 0,
      Emotion5.veryHappy: 0,
    };

    Iterable<MapEntry<DateTime, Emotion5>> entries;
    if (_scope == StatsScope.month) {
      final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final end = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      ).subtract(const Duration(days: 1));
      entries = _mainByDay.entries.where(
        (e) => !e.key.isBefore(start) && !e.key.isAfter(end),
      );
    } else {
      final start = DateTime(_selectedYear, 1, 1);
      final end = DateTime(_selectedYear, 12, 31);
      entries = _mainByDay.entries.where(
        (e) => !e.key.isBefore(start) && !e.key.isAfter(end),
      );
    }

    for (final e in entries) {
      c[e.value] = (c[e.value] ?? 0) + 1;
    }
    return c;
  }

  int get total => counts.values.sum;

  Map<Emotion5, double> get percents {
    final t = total;
    if (t == 0) {
      return {for (final emo in Emotion5.values) emo: 0.0};
    }
    final c = counts;
    return {for (final emo in Emotion5.values) emo: (c[emo]! * 100.0) / t};
  }

  // ================= NEW: các con số hiển thị trên chip =================

  /// Số ngày đã react trong tháng đang chọn
  int get reactedDaysInSelectedMonth {
    final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    ).subtract(const Duration(days: 1));
    return _mainByDay.keys
        .where((d) => !d.isBefore(start) && !d.isAfter(end))
        .length;
  }

  /// Số tháng trong năm đã react ĐẦY ĐỦ (không thiếu ngày nào)
  int get fullyReactedMonthsInSelectedYear {
    int full = 0;
    for (int m = 1; m <= 12; m++) {
      final days = DateUtils.getDaysInMonth(_selectedYear, m);
      bool allDaysHaveMood = true;
      for (int d = 1; d <= days; d++) {
        final key = DateTime(_selectedYear, m, d); // y/m/d 00:00
        if (!_mainByDay.containsKey(key)) {
          allDaysHaveMood = false;
          break;
        }
      }
      if (allDaysHaveMood) full++;
    }
    return full;
  }

  // -------------------- NEW: Streak dựa trên created_at --------------------

  DateTime _normalize(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Tập các NGÀY (00:00 local) mà người dùng đã **thực sự log** (dựa trên created_at).
  Set<DateTime> get _createdDays {
    final vm = _moodVM;
    if (vm == null) return <DateTime>{};
    final set = <DateTime>{};
    for (final m in vm.items) {
      // giả định model Mood có m.createdAt; nếu null thì fallback m.day
      final ca = m.createdAt ?? m.day;
      set.add(_normalize(ca));
    }
    return set;
  }

  /// Streak hiện tại:
  /// - Nếu hôm nay có log: đếm liên tiếp từ hôm nay lùi về.
  /// - Nếu hôm nay chưa log nhưng hôm qua có: đếm liên tiếp từ hôm qua lùi về.
  /// - Log quá khứ hôm nay tạo (backfill) sẽ KHÔNG kéo dài chuỗi cũ, vì created_at là hôm nay.
  int get currentStreak {
    final days = _createdDays;
    if (days.isEmpty) return 0;

    final today = _normalize(DateTime.now());
    DateTime? start;

    if (days.contains(today)) {
      start = today; // hôm nay có log → đếm từ hôm nay
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      if (days.contains(yesterday)) {
        start =
            yesterday; // hôm nay chưa log, nhưng hôm qua có → đếm từ hôm qua
      }
    }

    if (start == null) return 0;

    var d = start;
    var streak = 0;
    while (days.contains(d)) {
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
