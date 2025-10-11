import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:moodlyy_application/features/app/vm/notification_vm.dart';

class LocalNotificationsPort implements NotificationsPort {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // === PHẦN KHỞI TẠO TIMEZONE (ĐƠN GIẢN VÀ ỔN ĐỊNH NHẤT) ===

    // 1. Khởi tạo dữ liệu timezone
    // 2. Cố định múi giờ là Việt Nam để đảm bảo thông báo đúng giờ
    final String timeZoneName = 'Asia/Ho_Chi_Minh';

    // 3. Thiết lập nó làm location mặc định
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print(
      '✅ LocalNotificationsPort: Timezone đã được set thành: $timeZoneName',
    );

    // Init settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Android 13+ notifications permission
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Request POST_NOTIFICATIONS on Android 13+
      await androidImpl?.requestNotificationsPermission();

      // ✅ Android 12+ exact alarm permission (nếu có API; v17+ có)
      try {
        await androidImpl?.requestExactAlarmsPermission();
      } catch (_) {
        // Không sao: thiết bị/phiên bản plugin không hỗ trợ method này
      }
    }

    _initialized = true;
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    await init();

    // Tính thời điểm sắp tới
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(minutes: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'moodly_daily_channel',
      'Daily Notifications',
      channelDescription: 'Daily quote & streak reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    // ✅ Thử exact; nếu không được thì fallback inexact
    AndroidScheduleMode mode = AndroidScheduleMode.exactAllowWhileIdle;

    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.requestExactAlarmsPermission();
      try {
        final canExact =
            await androidImpl?.canScheduleExactNotifications() ?? false;
        debugPrint('⏰ Exact alarm permission: $canExact');
        if (!canExact) {
          debugPrint('⚠️ Exact alarm chưa được bật — Android sẽ bỏ qua alarm.');
          mode = AndroidScheduleMode.inexactAllowWhileIdle;
        }
      } catch (_) {
        // Thiết bị cũ / plugin cũ -> fallback inexact
        mode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }
    debugPrint(
      '🕒 scheduleDaily(): scheduling ID=$id '
      'for ${time.hour}:${time.minute} '
      '(now=${tz.TZDateTime.now(tz.local)})',
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // lặp mỗi ngày
      androidAllowWhileIdle: true, // ✅ Cho phép khi app bị sleep
      payload: 'scheduled_notification',
    );
    debugPrint('✅ Notification scheduled successfully at $scheduled');
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  /// 🔧 Tiện test: bắn thông báo ngay (không đợi lịch)
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'moodly_test_channel',
      'Test Notifications',
      channelDescription: 'One-shot test',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}

extension LocalNotificationsTestExt on LocalNotificationsPort {
  Future<void> testSchedule() async {
    await scheduleDaily(
      id: 1234,
      time: const TimeOfDay(hour: 0, minute: 1), // chỉnh giờ test tại đây
      title: 'Moodly Test',
      body: '⏰ Notification schedule test!',
    );
  }
}
