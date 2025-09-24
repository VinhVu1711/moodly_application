import 'package:flutter/material.dart';
import 'package:moodlyy_application/features/auth/data/auth_service.dart';

/// 📌 ViewModel quản lý trạng thái đăng nhập/đăng ký
class AuthVM extends ChangeNotifier {
  final AuthService _svc;
  AuthVM(this._svc);

  bool loading = false; //khai báo biến loading
  String? error;

  /// 🧠 Đăng nhập → cập nhật loading + error
  Future<void> login(String email, String password) async {
    loading = true; //loading bằng true để handle hiệu ứng quay tròn bên UI
    error = null; //error chưa có gì hết
    notifyListeners(); // báo UI là state đã đổi (loading = true)

    try {
      await _svc.login(email, password); //gọi đến xử lý đăng nhập
    } catch (e) {
      error = e.toString();
    }

    loading = false; //set lại biến loading để tắt hiệu ứng quay tròn bên UI
    notifyListeners(); // báo UI update lại
  }

  /// 🧠 Đăng ký tương tự
  Future<void> signup(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _svc.signup(email, password);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _svc.logout();
    } catch (e) {
      // Không bật loading để tránh UI nhấp nháy;
      // chỉ lưu lỗi nếu cần hiển thị ở Settings chẳng hạn.
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
}
