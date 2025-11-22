// lib/features/auth/data/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient sp;
  AuthService(this.sp) {
    // Session stream for authentication state
    _session$ = sp.auth.onAuthStateChange
        .map((e) {
          print('--- AUTH DEBUG ---');
          print('Event: ${e.event}');
          print('Session: ${e.session?.user.email}');
          return e.session;
        })
        .distinct((a, b) => a?.accessToken == b?.accessToken)
        .asBroadcastStream();
    
    // Password recovery event stream
    _passwordRecoveryEvent$ = sp.auth.onAuthStateChange
        .where((e) => e.event == AuthChangeEvent.passwordRecovery)
        .asBroadcastStream();
  }


  late final Stream<Session?> _session$;
  Stream<Session?> get session$ => _session$;
  
  late final Stream<AuthState> _passwordRecoveryEvent$;
  Stream<AuthState> get passwordRecoveryEvent$ => _passwordRecoveryEvent$;

  Session? get currentSession => sp.auth.currentSession;
  User? get currentUser => sp.auth.currentUser ?? sp.auth.currentSession?.user;
  String? get currentUserId => currentUser?.id;

  Future<void> login(String email, String password) =>
      sp.auth.signInWithPassword(email: email, password: password);

  Future<void> signup(String email, String password) =>
      sp.auth.signUp(email: email, password: password);

  Future<void> resetPasswordForEmail(String email) =>
      sp.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.moodlyy://callback/reset-password',
      );

  Future<void> updateUserPassword(String password) =>
      sp.auth.updateUser(UserAttributes(password: password));

  Future<void> logout() => sp.auth.signOut();
}
