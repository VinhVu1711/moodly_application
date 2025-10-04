import 'package:flutter/material.dart';

class UserSettings {
  final String userId;
  final String locale; // 'vi' | 'en'
  final String themeMode; // 'system' | 'light' | 'dark'
  final bool notifQuote;
  final bool notifStreak;

  UserSettings({
    required this.userId,
    required this.locale,
    required this.themeMode,
    required this.notifQuote,
    required this.notifStreak,
  });

  factory UserSettings.fromJson(Map<String, dynamic> j) => UserSettings(
    userId: j['user_id'] as String,
    locale: (j['locale'] as String?) ?? 'vi',
    themeMode: (j['theme_mode'] as String?) ?? 'system',
    notifQuote: (j['notif_quote'] as bool?) ?? false,
    notifStreak: (j['notif_streak'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'locale': locale,
    'theme_mode': themeMode,
    'notif_quote': notifQuote,
    'notif_streak': notifStreak,
  };

  UserSettings copyWith({
    String? locale,
    String? themeMode,
    bool? notifQuote,
    bool? notifStreak,
  }) => UserSettings(
    userId: userId,
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    notifQuote: notifQuote ?? this.notifQuote,
    notifStreak: notifStreak ?? this.notifStreak,
  );

  // --- Helpers (optional) ---
  static String themeModeToString(ThemeMode? m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  static ThemeMode stringToThemeMode(String? s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
