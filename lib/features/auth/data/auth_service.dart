// lib/features/auth/data/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient sp;
  AuthService(this.sp) {
    // Tạo 1 stream duy nhất, broadcast, reuse cho mọi nơi
    _session$ = sp.auth.onAuthStateChange
        .map((e) => e.session)
        .distinct((a, b) => a?.accessToken == b?.accessToken)
        .asBroadcastStream();
  }

  late final Stream<Session?> _session$;
  Stream<Session?> get session$ => _session$;

  Session? get currentSession => sp.auth.currentSession;
  User? get currentUser => sp.auth.currentUser ?? sp.auth.currentSession?.user;
  String? get currentUserId => currentUser?.id;

  Future<void> login(String email, String password) =>
      sp.auth.signInWithPassword(email: email, password: password);

  Future<void> signup(String email, String password) =>
      sp.auth.signUp(email: email, password: password);

  Future<void> logout() => sp.auth.signOut();
}
