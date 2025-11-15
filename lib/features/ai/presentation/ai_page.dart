import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

class _AiPageState extends State<AiPage> with SingleTickerProviderStateMixin {
  String mode = 'week';
  String month = '';
  String year = '';
  bool loading = false;
  String? adviceText;
  Map<String, dynamic>? result;
  final _monthKey = GlobalKey<FormFieldState>();
  final _yearKey = GlobalKey<FormFieldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      return true;
    } else if (mode == 'month') {
      return month.isNotEmpty &&
          year.isNotEmpty &&
          _validateMonth(month) == null &&
          _validateYear(year) == null;
    } else if (mode == 'year') {
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
      final res = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Connection timeout after 30 seconds',
                const Duration(seconds: 30),
              );
            },
          );

      if (res.statusCode != 200) {
        if (kDebugMode) {
          print("❌ GET_ADVICE failed: ${res.statusCode} ${res.body}");
        }
        final errorMsg = context.l10n.ai_error_server(res.statusCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
        setState(() => loading = false);
        return;
      }

      final Map<String, dynamic> data = jsonDecode(res.body);
      final String raw = data["ai_output"].toString().trim();

      String cleaned = raw
          .replaceAll(RegExp(r'^```json', multiLine: true), '')
          .replaceAll(RegExp(r'^```', multiLine: true), '')
          .replaceAll(RegExp(r'```$', multiLine: true), '')
          .trim();

      dynamic parsed;
      try {
        parsed = jsonDecode(cleaned);
      } catch (e) {
        if (kDebugMode) print("⚠️ JSON parse failed, using raw text: $e");
        parsed = {"summary": cleaned};
      }

      if (kDebugMode) print("✅ AI OUTPUT PARSED:\n$parsed");

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
      _animationController.forward(from: 0);
    } on TimeoutException {
      if (kDebugMode) print("⏱️ GET_ADVICE timeout");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ai_error_connection_timeout)),
        );
        setState(() => loading = false);
      }
    } on SocketException catch (e) {
      if (kDebugMode) print("🔌 GET_ADVICE connection error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ai_error_server_unavailable)),
        );
        setState(() => loading = false);
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) print("🌐 GET_ADVICE network error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ai_error_network)),
        );
        setState(() => loading = false);
      }
    } catch (e) {
      if (kDebugMode) print("⚠️ GET_ADVICE error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ai_error_unknown)),
        );
        setState(() => loading = false);
      }
    }
  }

  Widget _buildModeCard(String value, String label, IconData icon) {
    final isSelected = mode == value;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        setState(() {
          mode = value;
          if (mode != 'month') month = '';
          if (mode != 'month' && mode != 'year') year = '';
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(context.l10n.emotional_ai_title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section
            Container(
              color: colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.select_mode_title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModeCard(
                          'week',
                          context.l10n.week_title_ai,
                          Icons.calendar_view_week_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModeCard(
                          'month',
                          context.l10n.month_title,
                          Icons.calendar_month_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModeCard(
                          'year',
                          context.l10n.year_title,
                          Icons.calendar_today_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input fields with animation
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Column(
                      children: [
                        if (mode == 'month') ...[
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: _monthKey,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: context.l10n.month_title,
                                      hintText: '1-12',
                                      prefixIcon: Icon(
                                        Icons.calendar_month,
                                        color: colorScheme.primary,
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.error,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.error,
                                          width: 2,
                                        ),
                                      ),
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
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    key: _yearKey,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: context.l10n.year_title,
                                      hintText:
                                          '${DateTime.now().year - 5}-${DateTime.now().year}',
                                      prefixIcon: Icon(
                                        Icons.event,
                                        color: colorScheme.primary,
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.error,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.error,
                                          width: 2,
                                        ),
                                      ),
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
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (mode == 'year') ...[
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: TextFormField(
                                key: _yearKey,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: context.l10n.year_title,
                                  hintText:
                                      '${DateTime.now().year - 5}-${DateTime.now().year}',
                                  prefixIcon: Icon(
                                    Icons.event,
                                    color: colorScheme.primary,
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
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
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),

                  // Get Advice Button
                  FilledButton.icon(
                    onPressed: (loading || !_isInputValid())
                        ? null
                        : _getAdvice,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor:
                          colorScheme.surfaceContainerHighest,
                      disabledForegroundColor: colorScheme.onSurface
                          .withOpacity(0.38),
                    ),
                    icon: const Icon(Icons.psychology_rounded, size: 24),
                    label: Text(
                      context.l10n.get_advice_button,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result section
                  if (loading)
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Analyzing your emotional data...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (adviceText != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        elevation: 0,
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colorScheme.primary.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lightbulb_rounded,
                                      color: colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'AI Insights',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                adviceText!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (result != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              const JsonEncoder.withIndent(
                                '  ',
                              ).convert(result),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
