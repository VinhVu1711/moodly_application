import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuoteService {
  final SupabaseClient _sp;
  QuoteService(this._sp);

  static const _prefsKeyYmd = 'last_quote_shown_ymd';
  static const _prefsKeyId = 'last_quote_id';

  Future<bool> shouldShowTodayQuote() async {
    final p = await SharedPreferences.getInstance();
    final today = _ymd(DateTime.now());
    return p.getString(_prefsKeyYmd) != today;
  }

  /// Giữ API cũ để không phá chỗ gọi hiện tại (lưu chỉ theo ngày)
  Future<void> markShown() async {
    final p = await SharedPreferences.getInstance();
    final today = _ymd(DateTime.now());
    await p.setString(_prefsKeyYmd, today);
  }

  /// Nếu muốn lưu cả quoteId (đồng bộ trong ngày), dùng hàm này
  Future<void> markShownWithId({required int quoteId}) async {
    final p = await SharedPreferences.getInstance();
    final today = _ymd(DateTime.now());
    await p.setString(_prefsKeyYmd, today);
    await p.setInt(_prefsKeyId, quoteId);
  }

  /// Lấy quote hôm nay (ổn định trong ngày). Nếu đã hiển thị rồi, trả lại đúng quote cũ.
  Future<String> getTodayQuote({String lang = 'vi'}) async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final ymd = _ymd(today);

    // Nếu đã show hôm nay và có lưu id → lấy lại chính quote đó
    final savedYmd = p.getString(_prefsKeyYmd);
    final savedId = p.getInt(_prefsKeyId);
    if (savedYmd == ymd && savedId != null) {
      final reused = await _getQuoteById(savedId);
      if (reused != null) return reused;
    }

    try {
      // 1) Lấy danh sách id phù hợp (nhẹ vì chỉ có 1 cột)
      final rows = await _sp
          .from('daily_quotes')
          .select('id')
          .eq('active', true)
          .eq('lang', lang)
          .order('id');

      if (rows.isNotEmpty) {
        final total = rows.length;

        // 2) Tính index ổn định theo ngày + (tuỳ chọn) userId
        final uid = _sp.auth.currentUser?.id ?? '';
        final idx = _stableIndexFromString('$ymd|$uid', total);

        // 3) Lấy quote theo index (dùng range để chỉ lấy đúng 1 dòng)
        final selected = await _sp
            .from('daily_quotes')
            .select('id,text')
            .eq('active', true)
            .eq('lang', lang)
            .order('id')
            .range(idx, idx);

        if (selected.isNotEmpty) {
          final id = (selected.first['id'] as num).toInt();
          final text = selected.first['text'] as String;

          // Lưu lại để trong ngày trả đúng quote cũ (nếu em muốn)
          await markShownWithId(quoteId: id);

          return text;
        }
      }
    } catch (_) {
      // ignore, dùng fallback dưới
    }

    // Fallback nội bộ
    const quotesVi = [
      'Bạn đã đi được rất xa. Tiếp tục nhé!',
      'Hít sâu một hơi — mọi chuyện sẽ ổn.',
      'Nhỏ bước nhưng đều đặn sẽ thắng lớn.',
      'Hôm nay là một cơ hội mới.',
    ];
    final idx = _stableIndex(today, quotesVi.length);
    return quotesVi[idx];
  }

  Future<String?> _getQuoteById(int id) async {
    try {
      final res = await _sp
          .from('daily_quotes')
          .select('text')
          .eq('id', id)
          .maybeSingle();
      return res?['text'] as String?;
    } catch (_) {
      return null;
    }
  }

  static int _stableIndex(DateTime d, int mod) {
    final v = d.year * 10000 + d.month * 100 + d.day;
    return v % max(1, mod);
  }

  static int _stableIndexFromString(String s, int mod) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h % max(1, mod);
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
