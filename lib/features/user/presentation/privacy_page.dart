import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
// import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:moodlyy_application/features/user/vm/user_privacy_vm.dart';
import 'package:moodlyy_application/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserPrivacyVM>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.setting_privacy),
        elevation: 0,
      ),
      body: vm.loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.privacy_tip_rounded,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.setting_privacy_title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Change Password
                  FilledButton.icon(
                    icon: const Icon(Icons.lock_reset_rounded),
                    label: Text(context.l10n.setting_change_password),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final newPass = await _askPasswordDialog(
                        context,
                        title: context.l10n.setting_change_password,
                        hint: context.l10n.hint_new_password,
                      );
                      if (newPass != null && newPass.isNotEmpty) {
                        await vm.changePassword(newPass);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.msg_password_changed),
                            ),
                          );
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Delete Data
                  FilledButton.icon(
                    icon: const Icon(Icons.cleaning_services_rounded),
                    label: Text(context.l10n.setting_delete_data),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.tertiary,
                      foregroundColor: colorScheme.onTertiary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final email = vm.userEmail ?? '';
                      final pass = await _askPasswordDialog(
                        context,
                        title: context.l10n.setting_delete_data,
                        hint: context.l10n.hint_confirm_password(email),
                      );
                      if (pass != null && pass.isNotEmpty) {
                        await vm.deleteUserData(pass);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.msg_data_deleted),
                            ),
                          );
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Delete Account
                  FilledButton.icon(
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: Text(context.l10n.setting_delete_account),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final email = vm.userEmail ?? '';
                      final pass = await _askPasswordDialog(
                        context,
                        title: context.l10n.setting_delete_account,
                        hint: context.l10n.hint_confirm_password(email),
                      );
                      if (pass != null && pass.isNotEmpty) {
                        final ok = await _confirmDialog(
                          context,
                          title: context.l10n.confirm_delete_title,
                          message: context.l10n.confirm_delete_msg,
                        );
                        if (ok) {
                          await vm.deleteAccount(pass);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.msg_account_deleted),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<String?> _askPasswordDialog(
    BuildContext context, {
    required String title,
    required String hint,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          title,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.btn_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(t.btn_ok),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              title,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            content: Text(
              message,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.btn_cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: Text(t.setting_delete_account),
              ),
            ],
          ),
        ) ??
        false;
  }
}
