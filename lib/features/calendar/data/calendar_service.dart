import 'package:supabase_flutter/supabase_flutter.dart';

//Lấy ra những ngày nào trong 1 tháng mà người dùng có ghi mood
class CalendarService {
  final SupabaseClient _sp;
  CalendarService(this._sp);

  /// Trả về các ngày (UTC-normalized) có mood trong [monthStart, monthEnd]
  Future<Set<DateTime>> getMoodDaysInMonth({
    required String userId,
    required DateTime monthStart,
    required DateTime monthEnd,
  }) async {
    //Vào bảng moods, lấy cột created_at, lọc theo thời gian từ monthStart đến monthEnd và lọc theo UserID
    final res = await _sp
        .from('moods')
        .select('created_at')
        .gte('created_at', monthStart.toIso8601String())
        .lte('created_at', monthEnd.toIso8601String())
        .eq('user_id', userId);

    final set = <DateTime>{};
    for (final row in (res as List)) {
      final dt = DateTime.parse(row['created_at'] as String).toLocal();
      final day = DateTime(dt.year, dt.month, dt.day);
      set.add(day);
    }
    return set;
  }
}
