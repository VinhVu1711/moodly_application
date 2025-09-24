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
  //Không cần sử dụng dispose vì StatefulWidget đã handle việc này
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
    final vm = context.watch<AuthVM>(); // để rebuild khi loading/error thay đổi

    return Scaffold(
      appBar: AppBar(title: Text(isSignup ? 'Đăng ký' : 'Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (_) => context
                  .read<AuthVM>()
                  .clearError(), //khi thay đổi text ở trong ô nhập liệu sẽ xóa phần hiển thị lỗi
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              onChanged: (_) => context.read<AuthVM>().clearError(),
            ),
            const SizedBox(height: 12),

            if (vm.error != null) ...[
              Text(vm.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            //Kiểm tra xem có đang loading không
            vm.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: vm.loading
                        ? null
                        : () async {
                            final email = emailCtrl.text.trim();
                            final pass = passCtrl.text.trim();
                            if (isSignup) {
                              await context.read<AuthVM>().signup(email, pass);
                            } else {
                              await context.read<AuthVM>().login(email, pass);
                            }
                            // Không cần navigate ở đây. Redirect sẽ tự chạy khi session$ đổi.
                          },
                    child: Text(isSignup ? 'Tạo tài khoản' : 'Đăng nhập'),
                  ),

            TextButton(
              onPressed: () {
                setState(() => isSignup = !isSignup);
              },
              child: Text(
                isSignup ? 'Quay lại đăng nhập' : 'Chưa có tài khoản?',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
