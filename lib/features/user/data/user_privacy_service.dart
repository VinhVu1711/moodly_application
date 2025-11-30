import 'package:supabase_flutter/supabase_flutter.dart';

class UserPrivacyService {
  final SupabaseClient _client;
  UserPrivacyService(this._client);

  /// ✅ Reauthenticate bằng email + mật khẩu (bắt buộc trước khi xóa)
  Future<void> reauthenticate(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user == null) throw Exception('Invalid email or password');
  }

  /// 🔑 Đổi mật khẩu người dùng hiện tại
  Future<void> changePassword(String newPassword) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final res = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (res.user == null) throw Exception('Password change failed');
  }

  /// 🧹 Xóa dữ liệu cá nhân
  Future<void> deleteUserData(String userId) async {
    await _client.from('moods').delete().eq('user_id', userId);
    await _client.from('journal').delete().eq('user_id', userId);
  }

  /// ❌ Xóa tài khoản sau khi reauthenticate
  Future<void> deleteAccount(String email, String password) async {
    await reauthenticate(email, password); // bắt buộc nhập lại pass

    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await deleteUserData(user.id);

    // ⚠️ chỉ chạy được nếu dùng service_role key
    try {
      await _client.auth.admin.deleteUser(user.id);
    } catch (_) {
      await _client.auth.signOut();
      throw Exception('Account deletion requires admin privileges');
    }
  }
}
