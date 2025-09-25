import 'package:flutter/material.dart';
import '../../auth/data/auth_service.dart';
import '../data/calendar_service.dart';
import '../../mood/domain/mood.dart'; // ⬅️ để dùng Emotion5

class CalendarVM extends ChangeNotifier {
  final CalendarService _cal;
  final AuthService _auth;

  CalendarVM(this._cal, this._auth);

  final Color mint = const Color(0xFF90B7C2);

  DateTime focusedMonth = DateTime.now();
  bool highlightEnabled = true;
  Set<DateTime> moodDaysInMonth = {};

  /// ⬇️ NEW: filter theo cảm xúc chính (null = All)
  Emotion5? filterEmotion;
  bool get isFiltered => filterEmotion != null;

  /// ✅ Xoá sạch cache khi đổi session / sign out
  void clearAll() {
    focusedMonth = DateTime.now();
    moodDaysInMonth.clear();
    // giữ nguyên highlightEnabled
    filterEmotion = null; // ⬅️ clear luôn filter khi đổi user
    notifyListeners();
  }

  Future<void> init() async {
    await loadMonth(focusedMonth);
  }

  Future<void> loadMonth(DateTime month) async {
    focusedMonth = DateTime(month.year, month.month);

    final uid = _auth.currentUserId;
    if (uid == null) {
      // nếu chưa đăng nhập → dọn cache để tránh “lóe” data cũ
      moodDaysInMonth.clear();
      notifyListeners();
      return;
    }

    final start = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final end = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    // ⬇️ truyền filter xuống service (db-string)
    moodDaysInMonth = await _cal.getMoodDaysInMonth(
      userId: uid,
      monthStart: start.toUtc(),
      monthEnd: end.toUtc(),
      emotionDb: filterEmotion?.db, // null = lấy tất cả
    );
    notifyListeners();
  }

  void toggleHighlight() {
    highlightEnabled = !highlightEnabled;
    notifyListeners();
  }

  /// ⬇️ NEW: set/clear filter rồi reload tháng hiện tại
  Future<void> setFilterEmotion(Emotion5? e) async {
    filterEmotion = e;
    await loadMonth(focusedMonth);
  }

  bool hasMood(DateTime day) =>
      highlightEnabled &&
      moodDaysInMonth.contains(DateTime(day.year, day.month, day.day));
}
