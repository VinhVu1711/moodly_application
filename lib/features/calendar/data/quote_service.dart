import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Handle việc lấy ra câu nói mỗi ngày
class QuoteService {
  final SupabaseClient _sp;
  QuoteService(this._sp);

  //tên khóa lưu ngày mà hiển thị quote lần cuối
  static const _prefsKey = 'last_quote_shown_ymd';

  //có nên hiển thị quote ngày hôm nay không
  Future<bool> shouldShowTodayQuote() async {
    final p = await SharedPreferences.getInstance();
    final today = _ymd(DateTime.now()); //lấy ra ngày hôm nay
    return p.getString(_prefsKey) !=
        today; //kiểm tra xem ngày hôm nay đã show chưa
  }

  //đánh dấu là đã hiển thị quote ngày hôm nay rồi
  Future<void> markShown() async {
    final p = await SharedPreferences.getInstance();
    final today = _ymd(DateTime.now());
    await p.setString(_prefsKey, today); //ghi ngày hôm nay vào khóa
  }

  //lấy quote ngày hôm nay
  Future<String> getTodayQuote({String lang = 'vi'}) async {
    final today = DateTime.now();
    try {
      final res = await _sp
          .from('daily_quotes')
          .select('text')
          .eq('lang', lang)
          .order('id')
          .limit(1)
          .maybeSingle();
      final text = res?['text'] as String?;
      if (text != null && text.trim().isNotEmpty) return text;
    } catch (_) {
      /* fallback if table not ready */
    }

    // Fallback nội bộ: chọn theo hash ngày
    const quotesVi = [
      'Bạn đã đi được rất xa. Tiếp tục nhé!',
      'Hít sâu một hơi — mọi chuyện sẽ ổn.',
      'Nhỏ bước nhưng đều đặn sẽ thắng lớn.',
      'Hôm nay là một cơ hội mới.',
    ];
    final idx = _stableIndex(today, quotesVi.length);
    return quotesVi[idx];
  }

  //biến ngày thành số
  static int _stableIndex(DateTime d, int mod) {
    final v = d.year * 10000 + d.month * 100 + d.day;
    return (v % max(1, mod));
  }

  //Định dạng thành chuối ymd
  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
