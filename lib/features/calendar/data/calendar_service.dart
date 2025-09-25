import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarService {
  final SupabaseClient _sp;
  CalendarService(this._sp);

  /// Trả về các ngày (LOCAL normalized) có mood trong [monthStart, monthEnd]
  /// Nếu [emotionDb] != null thì lọc theo cảm xúc chính (ví dụ: 'happy')
  Future<Set<DateTime>> getMoodDaysInMonth({
    required String userId,
    required DateTime monthStart,
    required DateTime monthEnd,
    String? emotionDb, // ⬅️ NEW
  }) async {
    // dùng cột 'day' (DATE) để đúng với ý nghĩa “mood của ngày”
    final qb = _sp
        .from('moods')
        .select('day')
        .eq('user_id', userId)
        .gte(
          'day',
          DateTime(
            monthStart.year,
            monthStart.month,
            monthStart.day,
          ).toIso8601String(),
        )
        .lte(
          'day',
          DateTime(
            monthEnd.year,
            monthEnd.month,
            monthEnd.day,
          ).toIso8601String(),
        );

    if (emotionDb != null) {
      qb.eq('emotion', emotionDb);
    }

    final res = await qb;
    final set = <DateTime>{};
    for (final row in (res as List)) {
      final d = DateTime.parse(row['day'] as String).toLocal();
      set.add(DateTime(d.year, d.month, d.day));
    }
    return set;
  }
}
