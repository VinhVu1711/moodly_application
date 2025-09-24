import 'package:flutter/material.dart';
import '../../auth/data/auth_service.dart';
import '../data/calendar_service.dart';

class CalendarVM extends ChangeNotifier {
  final CalendarService _cal;
  final AuthService _auth;

  CalendarVM(this._cal, this._auth);

  final Color mint = const Color(0xFF90B7C2);

  DateTime focusedMonth = DateTime.now();
  bool highlightEnabled = true;
  Set<DateTime> moodDaysInMonth = {};

  /// ✅ BỔ SUNG: Xoá sạch cache khi đổi session / sign out
  void clearAll() {
    focusedMonth = DateTime.now();
    moodDaysInMonth.clear();
    // giữ nguyên highlightEnabled theo trạng thái hiện tại của user
    notifyListeners();
  }

  Future<void> init() async {
    await loadMonth(focusedMonth);
  }

  Future<void> loadMonth(DateTime month) async {
    focusedMonth = DateTime(month.year, month.month);

    final uid = _auth.currentUserId;
    if (uid == null) {
      // ✅ BỔ SUNG: nếu chưa đăng nhập → dọn cache để tránh “lóe” data cũ
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

    moodDaysInMonth = await _cal.getMoodDaysInMonth(
      userId: uid,
      monthStart: start.toUtc(),
      monthEnd: end.toUtc(),
    );
    notifyListeners();
  }

  void toggleHighlight() {
    highlightEnabled = !highlightEnabled;
    notifyListeners();
  }

  bool hasMood(DateTime day) =>
      highlightEnabled &&
      moodDaysInMonth.contains(DateTime(day.year, day.month, day.day));
}
