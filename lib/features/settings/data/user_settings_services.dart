import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_settings.dart';

class UserSettingsService {
  final SupabaseClient _sp;
  UserSettingsService(this._sp);

  /// Lấy settings của user (null nếu chưa có record)
  Future<UserSettings?> fetch(String userId) async {
    final j = await _sp
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (j == null) return null;
    return UserSettings.fromJson(j);
  }

  /// Upsert locale cho user (tạo mới nếu chưa có)
  Future<void> upsertLocale(String userId, String locale) async {
    await _sp.from('user_settings').upsert(
      {'user_id': userId, 'locale': locale},
      onConflict: 'user_id',
    ).select();
  }

  /// Upsert theme_mode: 'system' | 'light' | 'dark'
  Future<void> upsertThemeMode(String userId, String themeMode) async {
    await _sp.from('user_settings').upsert(
      {'user_id': userId, 'theme_mode': themeMode},
      onConflict: 'user_id',
    ).select();
  }

  /// Upsert notifications flags
  Future<void> upsertNotifications({
    required String userId,
    bool? notifQuote,
    bool? notifStreak,
  }) async {
    final payload = <String, dynamic>{'user_id': userId};
    if (notifQuote != null) payload['notif_quote'] = notifQuote;
    if (notifStreak != null) payload['notif_streak'] = notifStreak;

    await _sp
        .from('user_settings')
        .upsert(payload, onConflict: 'user_id')
        .select();
  }

  /// Lấy riêng trạng thái notification (quote / streak)
  Future<Map<String, bool>> fetchNotificationFlags(String userId) async {
    final j = await _sp
        .from('user_settings')
        .select('notif_quote, notif_streak')
        .eq('user_id', userId)
        .maybeSingle();

    if (j == null) return {'notif_quote': false, 'notif_streak': false};

    return {
      'notif_quote': (j['notif_quote'] as bool?) ?? false,
      'notif_streak': (j['notif_streak'] as bool?) ?? false,
    };
  }
}
