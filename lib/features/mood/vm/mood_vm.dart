import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../mood/domain/mood.dart';
import 'dart:collection'; // ADD: để trả về map chỉ-đọc
import 'dart:async';
import 'package:http/http.dart' as http;

DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

class MoodVM extends ChangeNotifier {
  final SupabaseClient _sb = Supabase.instance.client;

  /// Cache theo ngày (đã normalize) -> Mood
  final Map<DateTime, Mood> _byDay = {};
  bool _busy = false;

  // >>> NEW: loading state khi fetch theo tháng
  bool _loadingMonth = false;
  bool get isLoadingMonth => _loadingMonth;
  // <<< NEW

  bool get isBusy => _busy;

  Mood? moodOf(DateTime day) => _byDay[_normalize(day)];
  List<Mood> get items =>
      _byDay.values.toList()..sort((a, b) => a.day.compareTo(b.day));

  // >>> NEW: xoá toàn bộ cache & trạng thái (gọi khi session đổi)
  void clearAll() {
    _byDay.clear();
    _busy = false;
    _loadingMonth = false;
    notifyListeners();
  }
  // <<< NEW

  Future<String?> fetchMonth(int year, int month) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return 'Bạn chưa đăng nhập';

    // >>> NEW: bật cờ loading tháng (không thay đổi _busy hiện có)
    _loadingMonth = true;
    notifyListeners();
    // <<< NEW

    _busy = true;
    notifyListeners();
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(
        year,
        month + 1,
        1,
      ).subtract(const Duration(days: 1));
      final res = await _sb
          .from('moods')
          .select()
          .eq('user_id', uid)
          .gte('day', _normalize(start).toIso8601String())
          .lte('day', _normalize(end).toIso8601String())
          .order('day');

      // Gỡ cache của tháng đang lấy để tránh rác
      _byDay.removeWhere((k, _) => k.year == year && k.month == month);

      for (final row in (res as List)) {
        final m = Mood.fromJson(row as Map<String, dynamic>);
        _byDay[_normalize(m.day)] = m;
      }
      notifyListeners();

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _busy = false;
      // >>> NEW: tắt cờ loading tháng
      _loadingMonth = false;
      // <<< NEW
      notifyListeners();
    }
  }

  /// Load toàn bộ dữ liệu của 1 năm trong 1 truy vấn (giảm 12 calls)
  Future<String?> fetchYear(int year) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return 'Bạn chưa đăng nhập';

    // Không đụng tới _busy để không khoá UI; chỉ báo loading tháng chung
    _loadingMonth = true;
    notifyListeners();

    try {
      final start = DateTime(year, 1, 1);
      final end = DateTime(year, 12, 31);
      final res = await _sb
          .from('moods')
          .select()
          .eq('user_id', uid)
          .gte('day', _normalize(start).toIso8601String())
          .lte('day', _normalize(end).toIso8601String())
          .order('day');

      // Gỡ cache của năm để tránh rác
      _byDay.removeWhere((k, _) => k.year == year);

      for (final row in (res as List)) {
        final m = Mood.fromJson(row as Map<String, dynamic>);
        _byDay[_normalize(m.day)] = m;
      }
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _loadingMonth = false;
      notifyListeners();
    }
  }

  Future<String?> upsertDay({
    required DateTime day,
    required Emotion5 emotion,
    List<AnotherEmotion> another = const [],
    List<People> people = const [],
    String? note,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return 'Bạn chưa đăng nhập';
    _busy = true;
    notifyListeners();
    try {
      final mood = Mood(
        day: _normalize(day),
        emotion: emotion,
        another: another,
        people: people,
        note: note,
      );

      final inserted = await _sb
          .from('moods')
          .upsert(mood.toJson(uid), onConflict: 'user_id,day')
          .select()
          .single();

      final saved = Mood.fromJson(inserted);
      _byDay[_normalize(saved.day)] = saved;
      // Gọi auto sync sau 20 phút

      notifyListeners();
      final uri = Uri.parse("http://10.0.2.2:8000/refresh-data");
      final body = jsonEncode({"mode": "week"});
      Future.delayed(const Duration(seconds: 1), () async {
        try {
          final res = await http.post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: body,
          );
          if (kDebugMode) {
            print("🔄 REFRESH triggered: ${res.statusCode} ${res.body}");
          }
        } catch (e) {
          if (kDebugMode) print("⚠️ REFRESH error: $e");
        }
      });
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<String?> deleteDay(DateTime day) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return 'Bạn chưa đăng nhập';
    _busy = true;
    notifyListeners();
    try {
      await _sb
          .from('moods')
          .delete()
          .eq('user_id', uid)
          .eq('day', _normalize(day).toIso8601String());
      _byDay.remove(_normalize(day));
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
  // ===================== READ-ONLY VIEWS (ADD) =====================

  /// Map<DateTime, Mood> chỉ-đọc để UI có thể quan sát mà không sửa được.
  UnmodifiableMapView<DateTime, Mood> get byDay => UnmodifiableMapView(_byDay);

  /// Map<DateTime, Emotion5> cho thống kê (StatsVM dùng).
  /// Key đã được normalize theo 00:00 của ngày (giống _byDay).
  Map<DateTime, Emotion5> get mainEmotionByDay {
    final map = <DateTime, Emotion5>{};
    _byDay.forEach((day, mood) => map[day] = mood.emotion);
    return map;
  }

  // ===================== OPTIONAL HELPERS (ADD, không bắt buộc) =====================

  /// Kiểm tra trong cache đã có ÍT NHẤT 1 bản ghi của (year, month) hay chưa.
  bool hasMonthLoaded(int year, int month) =>
      _byDay.keys.any((d) => d.year == year && d.month == month);

  /// Đảm bảo dữ liệu tháng có trong cache; nếu chưa thì fetch.
  /// Trả về `null` nếu OK, hoặc message lỗi từ fetchMonth.
  Future<String?> ensureMonthLoaded(int year, int month) {
    if (hasMonthLoaded(year, month)) return Future.value(null);
    return fetchMonth(year, month);
  }
}
