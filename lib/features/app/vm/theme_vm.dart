// lib/features/app/vm/theme_vm.dart
import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moodlyy_application/features/settings/data/user_settings_services.dart';
import 'package:moodlyy_application/features/settings/domain/user_settings.dart';

class ThemeVM extends ChangeNotifier {
  static const _kKey = 'app_theme_mode'; // fallback chung
  static String _kKeyUser(String uid) => 'app_theme_mode:$uid';

  final UserSettingsService _svc;
  ThemeVM(this._svc);

  SharedPreferences? _sp;
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  String? _currentUserId;

  /// Gọi 1 lần lúc khởi động app
  Future<void> load() async {
    _sp = await SharedPreferences.getInstance();
    // đọc fallback chung để có default hợp lý khi chưa đăng nhập
    final s = _sp!.getString(_kKey);
    _mode = UserSettings.stringToThemeMode(s);
    notifyListeners();
  }

  /// Gọi khi session thay đổi
  Future<void> onUserChanged(String? userId) async {
    _currentUserId = userId;

    // 1) Nếu login 1 user cụ thể -> apply NGAY theme cache theo user đó (nếu có)
    if (userId != null && _sp != null) {
      final cached = _sp!.getString(_kKeyUser(userId));
      if (cached != null) {
        final m = UserSettings.stringToThemeMode(cached);
        if (m != _mode) {
          _mode = m;
          notifyListeners(); // ✨ áp theme ngay, tránh flash
        }
      }
    }

    // 2) Nếu logout -> quay về fallback chung (đã có sẵn trong _mode; optional có thể reload)
    if (userId == null) {
      // tuỳ chọn: đọc lại fallback _kKey nếu muốn
      final fallback = _sp?.getString(_kKey);
      final m = UserSettings.stringToThemeMode(fallback);
      if (m != _mode) {
        _mode = m;
        notifyListeners();
      }
      return;
    }

    // 3) Đồng bộ từ server (không chặn UI)
    try {
      final s = await _svc.fetch(userId);
      final serverMode = UserSettings.stringToThemeMode(s?.themeMode);
      if (serverMode != _mode) {
        _mode = serverMode;
        notifyListeners();
      }
      // cache lại theo user để lần sau apply tức thì
      await _sp?.setString(
        _kKeyUser(userId),
        UserSettings.themeModeToString(serverMode),
      );
    } catch (_) {
      // ignore: nếu lỗi mạng, đã có cache local nên không flash
    }
  }

  /// Đổi theme từ UI
  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();

    // ghi cache local
    final val = UserSettings.themeModeToString(mode);
    await _sp?.setString(_kKey, val);
    if (_currentUserId != null) {
      await _sp?.setString(_kKeyUser(_currentUserId!), val);
    }

    // sync server theo user (nếu có)
    if (_currentUserId != null) {
      try {
        await _svc.upsertThemeMode(_currentUserId!, val);
      } catch (_) {}
    }
  }

  String displayName(BuildContext context) {
    switch (_mode) {
      case ThemeMode.light:
        return context.l10n.setting_theme_light;
      case ThemeMode.dark:
        return context.l10n.setting_theme_dark;
      case ThemeMode.system:
        return context.l10n.setting_theme_system;
    }
  }
}
