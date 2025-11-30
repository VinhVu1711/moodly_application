import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// ⬇️ NEW: cần kiểu Session + 2 VM để gọi clearAll()
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodlyy_application/features/mood/vm/mood_vm.dart';
import 'package:moodlyy_application/features/calendar/vm/calendar_vm.dart';
import 'package:moodlyy_application/features/journal/vm/journal_vm.dart';

import 'package:moodlyy_application/features/mood/presentation/mood_edit_page.dart';
import 'package:moodlyy_application/features/auth/presentation/pages/login_page.dart';
import 'package:moodlyy_application/features/auth/presentation/pages/reset_password_page.dart';
import 'package:moodlyy_application/features/main_shell/presentation/app_shell.dart';
import 'package:moodlyy_application/features/auth/data/auth_service.dart';
import 'package:moodlyy_application/features/onboarding/presentation/intro_splash_page.dart';
import 'package:moodlyy_application/features/user/presentation/settings_page.dart';
import 'package:moodlyy_application/features/user/presentation/privacy_page.dart';
import 'package:moodlyy_application/features/user/presentation/about_page.dart';
import 'package:moodlyy_application/features/journal/presentation/journal_page.dart';

// NEW: i18n + LocaleVM
import 'package:moodlyy_application/l10n/app_localizations.dart';
import 'package:moodlyy_application/features/app/vm/locale_vm.dart';

// NEW: ThemeVM
import 'package:moodlyy_application/features/app/vm/theme_vm.dart';

// NEW: NotificationVM
import 'package:moodlyy_application/features/app/vm/notification_vm.dart';

/// ✅ Helper: Stream -> Listenable để dùng cho refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// ⬇️ Listener dọn cache khi session đổi + đồng bộ locale/theme/notification theo user
class AuthSessionListener extends StatefulWidget {
  final Widget child;
  const AuthSessionListener({super.key, required this.child});

  @override
  State<AuthSessionListener> createState() => _AuthSessionListenerState();
}

class _AuthSessionListenerState extends State<AuthSessionListener> {
  Session? _last;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = context.watch<Session?>();

    if (!identical(current, _last)) {
      // 🔧 Dời việc notifyListeners() sang frame kế tiếp để tránh lỗi
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        // clear caches data theo account
        context.read<MoodVM>().clearAll();
        context.read<CalendarVM>().clearAll();
        context.read<JournalVM>().clearAll();

        // ⬇️ sync settings theo user hiện tại
        final uid = current?.user.id;
        await context.read<LocaleVM>().onUserChanged(uid);
        await context.read<ThemeVM>().onUserChanged(uid);

        // ⬇️ sync notification theo user (toàn bộ logic nằm trong VM)
        // final notifVM = context.read<NotificationVM>();
        // if (uid != null) {
        //   await notifVM.syncForUser(uid);
        // }
      });
      _last = current;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 🔒 Giữ GoRouter 1 instance: tránh restart về /splash khi đổi locale
class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  GoRouter? _router;
  StreamSubscription? _passwordRecoverySub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Khởi tạo router duy nhất khi lần đầu có AuthService trong context
    if (_router == null) {
      final auth = context.read<AuthService>();
      _router = _buildRouter(auth);
      
      // Listen for password recovery events
      _passwordRecoverySub = auth.passwordRecoveryEvent$.listen((event) {
        print('🔑 PASSWORD_RECOVERY event detected! Navigating to /reset-password');
        // Navigate to reset password page
        _router!.go('/reset-password');
      });
    }
  }
  
  @override
  void dispose() {
    _passwordRecoverySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleVM>().locale;
    final themeMode = context.watch<ThemeVM>().mode; // NEW

    return AuthSessionListener(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router!, // giữ nguyên instance
        // i18n
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF90B7C2),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 234, 207, 207),
            foregroundColor: Colors.black,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF90B7C2),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: themeMode, // NEW: lấy theo ThemeVM (theo user)
      ),
    );
  }

  GoRouter _buildRouter(AuthService auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(auth.session$),
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const IntroSplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(
          path: '/reset-password',
          builder: (_, __) => const ResetPasswordPage(),
        ),

        // Home (tab Lịch mặc định)
        GoRoute(path: '/', builder: (_, __) => const AppShell()),

        // deep-link vào tab Biểu đồ
        GoRoute(
          path: '/stats',
          builder: (_, __) => const AppShell(initialIndex: 1),
        ),

        GoRoute(
          path: '/mood/new',
          builder: (_, state) =>
              MoodEditPage(day: (state.extra as DateTime?) ?? DateTime.now()),
        ),

        // User Settings Routes
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsPage(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (_, __) => const PrivacyPage(),
        ),
        GoRoute(
          path: '/about',
          builder: (_, __) => const AboutPage(),
        ),
        GoRoute(
          path: '/journal',
          builder: (_, __) => const JournalPage(),
        ),
      ],
      redirect: (ctx, state) {
        final session = auth.currentSession;
        final atSplash = state.matchedLocation == '/splash';
        final atLogin = state.matchedLocation == '/login';
        final atResetPassword = state.matchedLocation == '/reset-password';

        // Check if this is a password recovery flow from Supabase
        final isRecovery = state.uri.queryParameters['type'] == 'recovery';

        print('--- ROUTER DEBUG ---');
        print('Location: ${state.matchedLocation}');
        print('Uri: ${state.uri}');
        print('Uri.path: ${state.uri.path}');
        print('Uri.host: ${state.uri.host}');
        print('Query Params: ${state.uri.queryParameters}');
        print(
          'Session: ${session != null ? "Active (${session.user.email})" : "Null"}',
        );
        print(
          'AtSplash: $atSplash, AtLogin: $atLogin, AtResetPassword: $atResetPassword',
        );
        print('IsRecovery: $isRecovery');

        // Always allow splash screen
        if (atSplash) return null;

        // 🔧 FIX: Handle password recovery FIRST, before other checks
        if (isRecovery && session != null) {
          print('Recovery flow detected - redirecting to /reset-password');
          return '/reset-password';
        }

        // Allow access to reset-password page when session exists
        if (atResetPassword && session != null) {
          print('Allowing access to reset-password page');
          return null;
        }

        // No session: redirect to login (except if already at login)
        if (session == null) return atLogin ? null : '/login';

        // If logged in and at login page, go home
        if (atLogin) {
          print('Redirecting to / because atLogin is true and session exists');
          return '/';
        }

        return null;
      },
    );
  }
}
