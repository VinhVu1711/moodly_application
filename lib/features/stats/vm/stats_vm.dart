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

  // ------ nguồn dữ liệu (được bơm từ DI) ------
  MoodVM? _moodVM;

  // ADD: callback dùng cho add/removeListener
  void _onMoodChanged() => notifyListeners();

  void bindMoodVM(MoodVM vm) {
    if (!identical(_moodVM, vm)) {
      // REMOVE old listener nếu có
      _moodVM?.removeListener(_onMoodChanged);
      _moodVM = vm;
      // ADD listener mới
      _moodVM?.addListener(_onMoodChanged);
      notifyListeners(); // đổi nguồn → tính lại
    }
  }

  @override
  void dispose() {
    // REMOVE listener để tránh leak
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
  /// TODO: SỬA CHO KHỚP VỚI MODEL THỰC TẾ CỦA EM.
  /// Ví dụ giả định: MoodVM có Map<DateTime, Emotion5> mainEmotionByDay (chỉ 1 main/day).
  Map<DateTime, Emotion5> get _mainByDay {
    final vm = _moodVM;
    if (vm == null) return const {};
    // ↓↓↓ Thay dòng dưới bằng getter thực tế của em ↓↓↓
    return vm.mainEmotionByDay; // <-- ví dụ: map theo UTC 00:00 của từng ngày
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
      // year scope: 12 điểm, mỗi điểm là TRUNG BÌNH điểm score của các ngày trong tháng đó
      return List.generate(12, (i) {
        final month = i + 1;
        final start = DateTime(_selectedYear, month, 1);
        final end = DateTime(
          _selectedYear,
          month + 1,
          1,
        ).subtract(const Duration(days: 1));
        final entries = _mainByDay.entries.where(
          (e) => !e.key.isBefore(start) && !e.key.isAfter(end),
        );
        if (entries.isEmpty) return MoodPoint(month, null);
        final avg = entries
            .map((e) => e.value.score)
            .average; // from collection pkg
        return MoodPoint(month, avg);
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

  int get total => counts.values.sum; // tổng entry trong phạm vi

  Map<Emotion5, double> get percents {
    final t = total;
    if (t == 0) {
      return {
        for (final emo in Emotion5.values) emo: 0.0,
      };
    }
    final c = counts;
    return {
      for (final emo in Emotion5.values) emo: (c[emo]! * 100.0) / t,
    };
  }
}
