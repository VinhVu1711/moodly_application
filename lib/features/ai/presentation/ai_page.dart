import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AiPage extends StatefulWidget {
  const AiPage({Key? key}) : super(key: key);

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  String mode = 'week';
  String month = '';
  String year = '';
  String language = 'vn'; // ✅ Ngôn ngữ đầu ra
  bool loading = false;
  String? adviceText;
  Map<String, dynamic>? result;

  /// --- GỌI API /get-advice ---
  Future<void> _getAdvice() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập Supabase")),
      );
      return;
    }

    setState(() {
      loading = true;
      adviceText = null;
      result = null;
    });

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
          combinedText = "$summary\n\n💡 Lời khuyên:\n$advice";
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
      appBar: AppBar(title: const Text('AI Emotional Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Mode:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: mode,
              items: const [
                DropdownMenuItem(value: 'week', child: Text('Week')),
                DropdownMenuItem(value: 'month', child: Text('Month')),
                DropdownMenuItem(value: 'year', child: Text('Year')),
              ],
              onChanged: (v) => setState(() => mode = v ?? 'week'),
            ),
            if (mode == 'month') ...[
              TextField(
                decoration: const InputDecoration(labelText: 'Month (1–12)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => month = v,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Year (e.g. 2025)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => year = v,
              ),
            ],
            if (mode == 'year')
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Year (e.g. 2025)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => year = v,
              ),

            const SizedBox(height: 12),
            const Text('Select Language:', style: TextStyle(fontSize: 16)), // ✅
            DropdownButton<String>(
              value: language,
              items: const [
                DropdownMenuItem(value: 'vn', child: Text('Vietnamese')),
                DropdownMenuItem(value: 'eng', child: Text('English')),
              ],
              onChanged: (v) => setState(() => language = v ?? 'vn'),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _getAdvice,
              child: const Text('Get Advice'),
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
