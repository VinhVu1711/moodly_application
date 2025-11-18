import 'package:moodlyy_application/features/journal/domain/journal_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JournalService {
  JournalService(this._client);

  final SupabaseClient _client;

  Future<List<JournalEntry>> fetchEntries(String userId) async {
    final rows = List<Map<String, dynamic>>.from(
      await _client
          .from('journal')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false),
    );
    return rows.map(JournalEntry.fromJson).toList();
  }

  Future<JournalEntry> insertEntry({
    required String userId,
    required String content,
  }) async {
    final row = Map<String, dynamic>.from(
      await _client
          .from('journal')
          .insert({'user_id': userId, 'journal': content})
          .select()
          .single(),
    );
    return JournalEntry.fromJson(row);
  }

  Future<JournalEntry> updateEntry({
    required String id,
    required String userId,
    required String content,
  }) async {
    final row = Map<String, dynamic>.from(
      await _client
          .from('journal')
          .update({'journal': content})
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single(),
    );
    return JournalEntry.fromJson(row);
  }

  Future<void> deleteEntry({
    required String id,
    required String userId,
  }) async {
    await _client.from('journal').delete().eq('id', id).eq('user_id', userId);
  }
}
