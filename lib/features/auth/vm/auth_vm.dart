import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moodlyy_application/features/auth/data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // User, Session

/// 📌 ViewModel quản lý trạng thái đăng nhập/đăng ký + expose thông tin User
class AuthVM extends ChangeNotifier {
  final AuthService _svc;
  AuthVM(this._svc) {
    // Lắng nghe thay đổi phiên đăng nhập để UI tự cập nhật (email, avatar...)
    _sub = _svc.session$.listen((_) {
      // Mỗi khi session thay đổi (đăng nhập/đăng xuất/refresh token) → rebuild UI
      notifyListeners();
    });
  }

  late final StreamSubscription _sub;

  bool loading = false; // trạng thái quay vòng khi gọi API
  String? error; // thông báo lỗi gần nhất (nếu có)

  /// 👤 Lấy User hiện tại (null nếu chưa đăng nhập)
  User? get user => _svc.currentSession?.user;

  /// 🧠 Đăng nhập → cập nhật loading + error
  Future<void> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _svc.login(email, password);
      // session thay đổi -> listener ở trên sẽ notifyListeners() rồi
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 🧠 Đăng ký
  Future<void> signup(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _svc.signup(email, password);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 🚪 Đăng xuất
  Future<void> signOut() async {
    try {
      await _svc.logout();
      // session thay đổi -> listener ở trên sẽ notifyListeners()
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// 🔄 Xoá lỗi khi user chỉnh sửa input
  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel(); // tránh rò rỉ bộ nhớ
    super.dispose();
  }
}
