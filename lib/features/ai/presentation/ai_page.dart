import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moodlyy_application/features/app/vm/locale_vm.dart';

class AiPage extends StatefulWidget {
  const AiPage({Key? key}) : super(key: key);

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  String mode = 'week';
  String month = '';
  String year = '';
  bool loading = false;
  String? adviceText;
  Map<String, dynamic>? result;
  final _monthKey = GlobalKey<FormFieldState>();
  final _yearKey = GlobalKey<FormFieldState>();

  /// Validate month and year inputs
  String? _validateMonth(String? value) {
    if (mode == 'month') {
      if (value == null || value.isEmpty) {
        return 'Month is required';
      }
      final monthInt = int.tryParse(value);
      if (monthInt == null) {
        return 'Month must be a number';
      }
      if (monthInt < 1 || monthInt > 12) {
        return 'Month must be between 1 and 12';
      }
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (mode == 'month' || mode == 'year') {
      if (value == null || value.isEmpty) {
        return 'Year is required';
      }
      final yearInt = int.tryParse(value);
      if (yearInt == null) {
        return 'Year must be a number';
      }
      final currentYear = DateTime.now().year;
      final minYear = currentYear - 5;
      if (yearInt > currentYear) {
        return 'Year cannot be in the future';
      }
      if (yearInt < minYear) {
        return 'Year must be within the last 5 years';
      }
    }
    return null;
  }

  /// Check if all inputs are valid based on current mode
  bool _isInputValid() {
    if (mode == 'week') {
      return true; // Week mode doesn't require inputs
    } else if (mode == 'month') {
      // Both month and year must be valid
      return month.isNotEmpty &&
          year.isNotEmpty &&
          _validateMonth(month) == null &&
          _validateYear(year) == null;
    } else if (mode == 'year') {
      // Only year must be valid
      return year.isNotEmpty && _validateYear(year) == null;
    }
    return true;
  }

  /// --- GỌI API /get-advice ---
  Future<void> _getAdvice() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập Supabase")),
      );
      return;
    }

    // Validate inputs before making API call
    if (mode == 'month') {
      if (month.isEmpty || _validateMonth(month) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid month (1-12)")),
        );
        _monthKey.currentState?.validate();
        return;
      }
      if (year.isEmpty || _validateYear(year) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please enter a valid year (not in future, within last 5 years)",
            ),
          ),
        );
        _yearKey.currentState?.validate();
        return;
      }
    } else if (mode == 'year') {
      if (year.isEmpty || _validateYear(year) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please enter a valid year (not in future, within last 5 years)",
            ),
          ),
        );
        _yearKey.currentState?.validate();
        return;
      }
    }

    setState(() {
      loading = true;
      adviceText = null;
      result = null;
    });

    // Get current language from LocaleVM provider
    final localeVM = context.read<LocaleVM>();
    final locale = localeVM.locale;
    // Map locale language code to backend format: 'vi' -> 'vn', 'en' or null -> 'eng'
    final String language = locale?.languageCode == 'vi' ? 'vn' : 'eng';

    final uri = Uri.parse("http://10.0.2.2:8000/get-advice");
    final payload = {
      "user": uid,
      "mode": mode,
      "lan": language,
      if (mode == "month" && month.isNotEmpty) "month": int.tryParse(month),
      if ((mode == "month" || mode == "year") && year.isNotEmpty)
        "year": int.tryParse(year),
    };

    if (kDebugMode) print("🔍 Sending payload → $payload");

    try {
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (res.statusCode != 200) {
        if (kDebugMode) {
          print("❌ GET_ADVICE failed: ${res.statusCode} ${res.body}");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi lấy lời khuyên: ${res.statusCode}")),
        );
        setState(() => loading = false);
        return;
      }

      final Map<String, dynamic> data = jsonDecode(res.body);
      final String raw = data["ai_output"].toString().trim();

      // ✅ Làm sạch các ký tự thừa mà Gemini hay thêm
      String cleaned = raw
          .replaceAll(RegExp(r'^```json', multiLine: true), '')
          .replaceAll(RegExp(r'^```', multiLine: true), '')
          .replaceAll(RegExp(r'```$', multiLine: true), '')
          .trim();

      // ✅ Parse JSON an toàn
      dynamic parsed;
      try {
        parsed = jsonDecode(cleaned);
      } catch (e) {
        if (kDebugMode) print("⚠️ JSON parse failed, using raw text: $e");
        parsed = {"summary": cleaned};
      }

      if (kDebugMode) print("✅ AI OUTPUT PARSED:\n$parsed");

      // ✅ Chuyển JSON sang text đẹp
      String combinedText;
      if (parsed is Map) {
        final summary = parsed["summary"]?.toString().trim() ?? "";
        final advice = parsed["advice"]?.toString().trim() ?? "";
        if (summary.isNotEmpty && advice.isNotEmpty) {
          if (language == 'vn') {
            combinedText = "$summary\n\n💡 Lời khuyên:\n$advice";
          } else {
            combinedText = "$summary\n\n💡 Advice:\n$advice";
          }
        } else if (summary.isNotEmpty) {
          combinedText = summary;
        } else {
          combinedText = cleaned;
        }
      } else {
        combinedText = cleaned;
      }

      setState(() {
        result = data;
        adviceText = combinedText;
        loading = false;
      });
    } catch (e) {
      if (kDebugMode) print("⚠️ GET_ADVICE error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.emotional_ai_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.select_mode_title,
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
              value: mode,
              items: [
                DropdownMenuItem(
                  value: 'week',
                  child: Text(context.l10n.week_title_ai),
                ),
                DropdownMenuItem(
                  value: 'month',
                  child: Text(context.l10n.month_title),
                ),
                DropdownMenuItem(
                  value: 'year',
                  child: Text(context.l10n.year_title),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  mode = v ?? 'week';
                  // Clear inputs when mode changes
                  if (mode != 'month') month = '';
                  if (mode != 'month' && mode != 'year') year = '';
                });
              },
            ),
            if (mode == 'month') ...[
              TextFormField(
                key: _monthKey,
                decoration: InputDecoration(
                  labelText: context.l10n.month_title,
                  hintText: '1-12',
                ),
                keyboardType: TextInputType.number,
                initialValue: month,
                validator: _validateMonth,
                onChanged: (v) {
                  setState(() {
                    month = v;
                  });
                  _monthKey.currentState?.validate();
                },
                onSaved: (v) => month = v ?? '',
              ),
              TextFormField(
                key: _yearKey,
                decoration: InputDecoration(
                  labelText: context.l10n.year_title,
                  hintText: '${DateTime.now().year - 5}-${DateTime.now().year}',
                ),
                keyboardType: TextInputType.number,
                initialValue: year,
                validator: _validateYear,
                onChanged: (v) {
                  setState(() {
                    year = v;
                  });
                  _yearKey.currentState?.validate();
                },
                onSaved: (v) => year = v ?? '',
              ),
            ],
            if (mode == 'year')
              TextFormField(
                key: _yearKey,
                decoration: InputDecoration(
                  labelText: context.l10n.year_title,
                  hintText: '${DateTime.now().year - 5}-${DateTime.now().year}',
                ),
                keyboardType: TextInputType.number,
                initialValue: year,
                validator: _validateYear,
                onChanged: (v) {
                  setState(() {
                    year = v;
                  });
                  _yearKey.currentState?.validate();
                },
                onSaved: (v) => year = v ?? '',
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (loading || !_isInputValid()) ? null : _getAdvice,
              child: Text(context.l10n.get_advice_button),
            ),
            const SizedBox(height: 20),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (adviceText != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    adviceText!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              )
            else if (result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    const JsonEncoder.withIndent('  ').convert(result),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
