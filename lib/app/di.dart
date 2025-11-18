import 'package:moodlyy_application/features/app/notification/local_notifications_port.dart';
import 'package:moodlyy_application/features/app/vm/notification_vm.dart';
import 'package:moodlyy_application/features/app/vm/notification_vm.dart'
    show NotificationsPort; // dùng interface
import 'package:moodlyy_application/features/auth/data/auth_service.dart';
import 'package:moodlyy_application/features/auth/vm/auth_vm.dart';
import 'package:moodlyy_application/features/calendar/data/calendar_service.dart';
import 'package:moodlyy_application/features/calendar/vm/calendar_vm.dart';
import 'package:moodlyy_application/features/mood/vm/mood_vm.dart';
import 'package:moodlyy_application/features/user/data/user_privacy_service.dart';
import 'package:moodlyy_application/features/user/vm/user_privacy_vm.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// NEW: StatsVM
import 'package:moodlyy_application/features/stats/vm/stats_vm.dart';

// NEW: LocaleVM (i18n)
import 'package:moodlyy_application/features/app/vm/locale_vm.dart';

// NEW: ThemeVM (giao diện)
import 'package:moodlyy_application/features/app/vm/theme_vm.dart';

// NEW: UserSettingsService (persist settings theo user)
import 'package:moodlyy_application/features/settings/data/user_settings_services.dart';

// NEW: NotificationVM (state bật/tắt notification theo user)
import 'package:moodlyy_application/features/app/vm/notification_vm.dart';

// Journal feature
import 'package:moodlyy_application/features/journal/data/journal_service.dart';
import 'package:moodlyy_application/features/journal/vm/journal_vm.dart';

List<SingleChildWidget> buildProviders() => [
  // 1️⃣ Supabase client
  Provider<SupabaseClient>(create: (_) => Supabase.instance.client),

  // 2️⃣ Services
  ProxyProvider<SupabaseClient, AuthService>(
    update: (_, sp, __) => AuthService(sp),
  ),
  ProxyProvider<SupabaseClient, UserSettingsService>(
    update: (_, sp, __) => UserSettingsService(sp),
  ),
  ProxyProvider<SupabaseClient, CalendarService>(
    update: (_, sp, __) => CalendarService(sp),
  ),
  ProxyProvider<SupabaseClient, JournalService>(
    update: (_, sp, __) => JournalService(sp),
  ),
  // ✅ Thêm dòng này — thiếu trong file của em
  ProxyProvider<SupabaseClient, UserPrivacyService>(
    update: (_, sp, __) => UserPrivacyService(sp),
  ),

  // 3️⃣ NotificationsPort triển khai thật
  Provider<NotificationsPort>(
    create: (_) => LocalNotificationsPort()..init(),
  ),

  // 4️⃣ Streams
  StreamProvider<Session?>(
    initialData: Supabase.instance.client.auth.currentSession,
    create: (ctx) => ctx.read<AuthService>().session$,
  ),

  // 5️⃣ ViewModels
  ChangeNotifierProvider<AuthVM>(
    create: (ctx) => AuthVM(ctx.read<AuthService>()),
  ),
  ChangeNotifierProvider<LocaleVM>(
    create: (ctx) => LocaleVM(ctx.read<UserSettingsService>())..load(),
  ),
  ChangeNotifierProvider<ThemeVM>(
    create: (ctx) => ThemeVM(ctx.read<UserSettingsService>())..load(),
  ),
  ChangeNotifierProvider<NotificationVM>(
    create: (ctx) => NotificationVM(
      ctx.read<UserSettingsService>(),
      ctx.read<NotificationsPort>(),
    ),
  ),
  ChangeNotifierProvider<CalendarVM>(
    create: (ctx) => CalendarVM(
      ctx.read<CalendarService>(),
      ctx.read<AuthService>(),
    ),
  ),
  ChangeNotifierProvider<MoodVM>(create: (_) => MoodVM()),
  ChangeNotifierProvider<JournalVM>(
    create: (ctx) => JournalVM(
      ctx.read<JournalService>(),
      ctx.read<AuthService>(),
    ),
  ),

  ChangeNotifierProxyProvider<MoodVM, StatsVM>(
    create: (_) => StatsVM(),
    update: (_, moodVM, stats) {
      stats ??= StatsVM();
      stats.bindMoodVM(moodVM);
      return stats;
    },
  ),

  // ✅ PrivacyVM (đã có service)
  ChangeNotifierProvider<UserPrivacyVM>(
    create: (ctx) => UserPrivacyVM(
      ctx.read<UserPrivacyService>(),
      ctx.read<SupabaseClient>(),
    ),
  ),
];
