import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moodlyy_application/features/settings/data/user_settings_services.dart';

/// Cổng trừu tượng để schedule/cancel thông báo.
/// App của em có thể inject implementation thật (flutter_local_notifications, awesome_notifications, FCM, ...).
abstract class NotificationsPort {
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  });

  Future<void> cancel(int id);
}

/// Mặc định: no-op (không làm gì). Giữ nguyên logic hiện tại nếu chưa tích hợp service thật.
class NullNotificationsPort implements NotificationsPort {
  @override
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

class NotificationVM extends ChangeNotifier {
  final UserSettingsService _service;
  final NotificationsPort _port;

  NotificationVM(this._service, [NotificationsPort? port])
    : _port = port ?? NullNotificationsPort();

  // Trạng thái bật/tắt theo user (đọc từ DB)
  bool notifQuote = false;
  bool notifStreak = false;

  // ID và khung giờ cố định
  static const int _quoteId = 1001;
  static const int _streakId = 1002;

  static const TimeOfDay _quoteTime = TimeOfDay(hour: 8, minute: 0); // 08:00
  static const TimeOfDay _streakTime = TimeOfDay(hour: 20, minute: 24); // 20:00

  static const String _title = 'Moodly';
  static const String _quoteBody = "Don't forget to check your quote today!";
  static const String _streakBody = "Keep your streak now! Don't lose it";

  /// Đọc cờ từ DB → cập nhật state (không schedule ở đây).
  Future<void> load(String userId) async {
    final flags = await _service.fetchNotificationFlags(userId);
    notifQuote = flags['notif_quote'] ?? false;
    notifStreak = flags['notif_streak'] ?? false;
    notifyListeners();
  }

  /// Đồng bộ FULL cho 1 user: load cờ + schedule theo cờ hiện tại.
  Future<void> syncForUser(String userId) async {
    await load(userId);
    await _applySchedule();
  }

  /// Bật/tắt quote → lưu DB → reschedule theo trạng thái mới.
  Future<void> toggleQuote(String userId, bool value) async {
    notifQuote = value;
    await _service.upsertNotifications(userId: userId, notifQuote: value);
    await _applySchedule();
    notifyListeners();
  }

  /// Bật/tắt streak → lưu DB → reschedule theo trạng thái mới.
  Future<void> toggleStreak(String userId, bool value) async {
    notifStreak = value;
    await _service.upsertNotifications(userId: userId, notifStreak: value);
    await _applySchedule();
    notifyListeners();
  }

  /// Áp dụng lịch theo state hiện tại (gọi cổng NotificationsPort).
  Future<void> _applySchedule() async {
    if (notifQuote) {
      await _port.scheduleDaily(
        id: _quoteId,
        time: _quoteTime,
        title: _title,
        body: _quoteBody,
      );
    } else {
      await _port.cancel(_quoteId);
    }

    if (notifStreak) {
      await _port.scheduleDaily(
        id: _streakId,
        time: _streakTime,
        title: _title,
        body: _streakBody,
      );
    } else {
      await _port.cancel(_streakId);
    }
    debugPrint(
      '🔔 Applying schedule: notifQuote=$notifQuote, notifStreak=$notifStreak',
    );
  }
}
