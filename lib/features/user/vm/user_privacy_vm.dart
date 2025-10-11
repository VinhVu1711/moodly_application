import 'package:flutter/material.dart';
import 'package:moodlyy_application/features/user/data/user_privacy_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPrivacyVM extends ChangeNotifier {
  final UserPrivacyService _service;
  final SupabaseClient _client;
  bool loading = false;

  UserPrivacyVM(this._service, this._client);

  String? get userId => _client.auth.currentUser?.id;
  String? get userEmail => _client.auth.currentUser?.email;

  Future<void> changePassword(String newPassword) async {
    _start();
    try {
      await _service.changePassword(newPassword);
    } finally {
      _stop();
    }
  }

  Future<void> deleteUserData(String password) async {
    if (userId == null || userEmail == null) return;
    _start();
    try {
      await _service.reauthenticate(userEmail!, password);
      await _service.deleteUserData(userId!);
    } finally {
      _stop();
    }
  }

  Future<void> deleteAccount(String password) async {
    if (userEmail == null) return;
    _start();
    try {
      await _service.deleteAccount(userEmail!, password);
      await _client.auth.signOut();
    } finally {
      _stop();
    }
  }

  void _start() {
    loading = true;
    notifyListeners();
  }

  void _stop() {
    loading = false;
    notifyListeners();
  }
}
