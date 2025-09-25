import 'package:moodlyy_application/features/auth/data/auth_service.dart';
import 'package:moodlyy_application/features/auth/vm/auth_vm.dart';
import 'package:moodlyy_application/features/calendar/data/calendar_service.dart';
import 'package:moodlyy_application/features/calendar/vm/calendar_vm.dart';
import 'package:moodlyy_application/features/mood/vm/mood_vm.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// NEW: import StatsVM
import 'package:moodlyy_application/features/stats/vm/stats_vm.dart';

List<SingleChildWidget> buildProviders() => [
  // 1) Supabase client
  Provider<SupabaseClient>(create: (_) => Supabase.instance.client),

  // 2) Services
  ProxyProvider<SupabaseClient, AuthService>(
    update: (_, sp, __) => AuthService(sp),
  ),

  // 3) Stream session (dùng CHUNG auth.session$)
  StreamProvider<Session?>(
    initialData: Supabase.instance.client.auth.currentSession,
    create: (ctx) => ctx.read<AuthService>().session$,
  ),

  // 4) ViewModels
  ChangeNotifierProvider<AuthVM>(
    create: (ctx) => AuthVM(ctx.read<AuthService>()),
  ),
  ProxyProvider<SupabaseClient, CalendarService>(
    update: (_, sp, __) => CalendarService(sp),
  ),
  ChangeNotifierProvider<CalendarVM>(
    create: (ctx) => CalendarVM(
      ctx.read<CalendarService>(),
      ctx.read<AuthService>(),
    ),
  ),
  ChangeNotifierProvider<MoodVM>(create: (_) => MoodVM()),

  // NEW: StatsVM phụ thuộc MoodVM → dùng ProxyProvider để bind dữ liệu nguồn
  ChangeNotifierProxyProvider<MoodVM, StatsVM>(
    create: (_) => StatsVM(),
    update: (_, moodVM, stats) {
      stats ??= StatsVM();
      stats.bindMoodVM(moodVM);
      return stats;
    },
  ),
];
