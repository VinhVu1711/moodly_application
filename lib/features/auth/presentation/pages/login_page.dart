// lib/features/auth/presentation/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moodlyy_application/features/auth/vm/auth_vm.dart';

/// 📌 Giao diện Login/Signup
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  bool isSignup = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthVM>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    colorScheme.surface,
                    colorScheme.surfaceVariant,
                  ]
                : [
                    colorScheme.primaryContainer.withValues(alpha: 0.3),
                    colorScheme.secondaryContainer.withValues(alpha: 0.2),
                    const Color.fromARGB(
                      255,
                      234,
                      207,
                      207,
                    ).withValues(alpha: 0.4),
                  ],
            stops: isDark ? [0.0, 1.0] : [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outline.withValues(
                          alpha: 0.15,
                        ), // 👈 Slightly lighter
                        width: 1.0, // ✅ Thinner border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        12.0,
                      ), // ✅ Reduced padding → more space for image
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          80,
                        ), // Half of 160 → perfect circle
                        child: Image.asset(
                          'assets/images/moodly_logo.png',
                          fit: BoxFit.cover, // Fills the circle cleanly
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App Title
                  Text(
                    'Moodly',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    isSignup ? 'Tạo tài khoản mới' : 'Chào mừng trở lại',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Container
                  Card(
                    elevation: 8,
                    shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Email Field
                          TextField(
                            controller: emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceVariant.withValues(
                                alpha: 0.3,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onChanged: (_) =>
                                context.read<AuthVM>().clearError(),
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextField(
                            controller: passCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceVariant.withValues(
                                alpha: 0.3,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onChanged: (_) =>
                                context.read<AuthVM>().clearError(),
                          ),
                          const SizedBox(height: 8),

                          // Forgot Password Button
                          if (!isSignup)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () async {
                                  final email = emailCtrl.text.trim();
                                  if (email.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Vui lòng nhập email trước'),
                                      ),
                                    );
                                    return;
                                  }
                                  await context
                                      .read<AuthVM>()
                                      .resetPassword(email);
                                  if (context.mounted) {
                                    final error = context.read<AuthVM>().error;
                                    if (error == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Đã gửi email đặt lại mật khẩu'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Quên mật khẩu?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Error Message
                          if (vm.error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colorScheme.onErrorContainer,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      vm.error!,
                                      style: TextStyle(
                                        color: colorScheme.onErrorContainer,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Login/Signup Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: vm.loading
                                ? FilledButton(
                                    onPressed: null,
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: colorScheme.onPrimary,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : FilledButton(
                                    onPressed: vm.loading
                                        ? null
                                        : () async {
                                            final email = emailCtrl.text.trim();
                                            final pass = passCtrl.text.trim();
                                            if (isSignup) {
                                              await context
                                                  .read<AuthVM>()
                                                  .signup(email, pass);
                                            } else {
                                              await context
                                                  .read<AuthVM>()
                                                  .login(email, pass);
                                            }
                                          },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      isSignup ? 'Tạo tài khoản' : 'Đăng nhập',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Toggle Button
                          TextButton(
                            onPressed: () {
                              setState(() => isSignup = !isSignup);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: isSignup
                                        ? 'Đã có tài khoản? '
                                        : 'Chưa có tài khoản? ',
                                  ),
                                  TextSpan(
                                    text: isSignup ? 'Đăng nhập' : 'Đăng ký',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
