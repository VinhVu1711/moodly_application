// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  debugPrint('✅ Supabase initialized');
  // 3️⃣ Khởi tạo notification plugin (rất quan trọng)
  // final localNoti = LocalNotificationsPort();
  // await localNoti.init();
  // debugPrint('✅ LocalNotificationsPort initialized');
  // 4️⃣ (Tùy chọn) Test xem có hiện được notification ngay không

  // Chạy ứng dụng
  runApp(const MoodlyyyApp());
}
