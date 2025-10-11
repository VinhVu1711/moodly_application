// main.dart
import 'package:flutter/material.dart';
import 'package:moodlyy_application/app/app.dart';
import 'package:moodlyy_application/features/app/notification/local_notifications_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1️⃣ Khởi tạo timezone (bắt buộc cho schedule)
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  debugPrint('🕐 Timezone initialized: Asia/Ho_Chi_Minh');
  // 2️⃣ Khởi tạo Supabase
  await Supabase.initialize(
    url: 'https://dznyqpjisucohdvcjxid.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6bnlxcGppc3Vjb2hkdmNqeGlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1NjAwOTIsImV4cCI6MjA3MzEzNjA5Mn0.lSKmjBRkzmIvQZaxZqQlQtNIfOFoExAw8WZIUxS6764',
  );
  debugPrint('✅ Supabase initialized');
  // 3️⃣ Khởi tạo notification plugin (rất quan trọng)
  final localNoti = LocalNotificationsPort();
  await localNoti.init();
  debugPrint('✅ LocalNotificationsPort initialized');
  // 4️⃣ (Tùy chọn) Test xem có hiện được notification ngay không

  // Chạy ứng dụng
  runApp(const MoodlyyyApp());
}
