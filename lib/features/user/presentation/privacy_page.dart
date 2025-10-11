import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moodlyy_application/features/user/vm/user_privacy_vm.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserPrivacyVM>();

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Change Password'),
                    onPressed: () async {
                      final newPass = await _askPassword(context);
                      if (newPass != null) {
                        await vm.changePassword(newPass);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password updated!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Delete My Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () async {
                      final pass = await _askPassword(context);
                      if (pass == null || pass.isEmpty) return;
                      await vm.deleteUserData(pass);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All data deleted!')),
                      );
                    },
                  ),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete My Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final pass = await _askPassword(context);
                      if (pass == null || pass.isEmpty) return;
                      final ok = await _confirmDelete(context);
                      if (ok) {
                        await vm.deleteAccount(pass);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account deleted')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<String?> _askPassword(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter new password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'New password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete account?'),
            content: const Text('This action cannot be undone!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
