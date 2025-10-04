import 'package:flutter/material.dart';
import 'package:moodlyy_application/features/settings/data/user_settings_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleVM extends ChangeNotifier {
  static const _kKey = 'app_locale_code';

  final UserSettingsService _svc;
  LocaleVM(this._svc);

  Locale? _locale; // null = theo hệ thống
  String? _currentUserId; // user hiện tại (để biết persist cho ai)

  Locale? get locale => _locale;

  /// Giữ nguyên hành vi cũ: load từ SharedPreferences (dùng khi app khởi động
  /// hoặc khi đã đăng xuất). Không gọi Supabase ở đây.
  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_kKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    } else {
      _locale = null; // theo hệ thống
    }
    notifyListeners();
  }

  /// NEW: gọi khi session đổi (đăng nhập/đăng xuất).
  /// - userId == null  -> trở về cấu hình local (SP)
  /// - userId != null  -> đọc settings từ Supabase; nếu chưa có, dùng SP làm fallback
  Future<void> onUserChanged(String? userId) async {
    _currentUserId = userId;

    if (userId == null) {
      // Đăng xuất: quay về cấu hình local
      await load();
      return;
    }

    try {
      final settings = await _svc.fetch(userId);
      if (settings != null && settings.locale.isNotEmpty) {
        _locale = Locale(settings.locale);
      } else {
        // Fallback: nếu chưa có bản ghi trên server, dùng cấu hình cục bộ
        final sp = await SharedPreferences.getInstance();
        final code = sp.getString(_kKey);
        _locale = (code != null && code.isNotEmpty) ? Locale(code) : null;
      }
      notifyListeners();
    } catch (_) {
      // Lỗi mạng/server → không crash, giữ nguyên locale hiện tại
    }
  }

  /// Đổi locale:
  /// - update state + notify
  /// - lưu SharedPreferences
  /// - nếu đang đăng nhập → upsert Supabase cho user hiện tại
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();

    final sp = await SharedPreferences.getInstance();
    if (locale == null) {
      await sp.remove(_kKey);
    } else {
      await sp.setString(_kKey, locale.languageCode);
    }

    // Persist theo user trên Supabase nếu đã đăng nhập
    if (_currentUserId != null && locale != null) {
      try {
        await _svc.upsertLocale(_currentUserId!, locale.languageCode);
      } catch (_) {
        // Có thể log hoặc show thông báo mềm nếu muốn; không chặn UI
      }
    }
  }

  /// Label hiển thị trong Settings
  String displayName() {
    if (_locale == null) return 'System';
    return _locale!.languageCode == 'vi' ? 'Tiếng Việt' : 'English';
  }
}
