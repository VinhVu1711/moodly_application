import 'package:flutter/material.dart';
import 'package:moodlyy_application/features/auth/data/auth_service.dart';
import 'package:moodlyy_application/features/journal/data/journal_service.dart';
import 'package:moodlyy_application/features/journal/domain/journal_entry.dart';

class JournalVM extends ChangeNotifier {
  static const String notAuthenticated = 'not_authenticated';

  JournalVM(this._service, this._auth);

  final JournalService _service;
  final AuthService _auth;

  final List<JournalEntry> _entries = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  JournalEntry? get latestEntry => _entries.isEmpty ? null : _entries.first;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  void clearAll() {
    _entries.clear();
    _isLoading = false;
    _isSaving = false;
    _error = null;
    notifyListeners();
  }

  Future<String?> loadEntries() async {
    final uid = _auth.currentUserId;
    if (uid == null) {
      _entries.clear();
      _error = notAuthenticated;
      notifyListeners();
      return _error;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchEntries(uid);
      _entries
        ..clear()
        ..addAll(data);
      _error = null;
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> saveEntry(String content) {
    final current = latestEntry;
    if (current == null) {
      return addEntry(content);
    }
    return updateEntry(id: current.id, content: content);
  }

  Future<String?> addEntry(String content) async {
    final uid = _auth.currentUserId;
    if (uid == null) return notAuthenticated;

    _isSaving = true;
    notifyListeners();

    try {
      final inserted = await _service.insertEntry(
        userId: uid,
        content: content.trim(),
      );
      _entries.insert(0, inserted);
      _error = null;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> updateEntry({
    required String id,
    required String content,
  }) async {
    final uid = _auth.currentUserId;
    if (uid == null) return notAuthenticated;

    _isSaving = true;
    notifyListeners();

    try {
      final updated = await _service.updateEntry(
        id: id,
        userId: uid,
        content: content.trim(),
      );
      final idx = _entries.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _entries[idx] = updated;
      }
      _error = null;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> deleteEntry(String id) async {
    final uid = _auth.currentUserId;
    if (uid == null) return notAuthenticated;

    try {
      await _service.deleteEntry(id: id, userId: uid);
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      return _error;
    }
  }
}
