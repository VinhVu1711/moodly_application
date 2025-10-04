import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:provider/provider.dart';

import 'package:moodlyy_application/features/auth/vm/auth_vm.dart';
// i18n
import 'package:moodlyy_application/l10n/app_localizations.dart';

// Locale Provider
import 'package:moodlyy_application/features/app/vm/locale_vm.dart';
// NEW: Theme Provider
import 'package:moodlyy_application/features/app/vm/theme_vm.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!;

    // Lấy email thật từ AuthVM nếu có
    final email = context.select<AuthVM, String?>((vm) => vm.user?.email);

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        // Header Section
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF90B7C2).withOpacity(0.3),
                      theme.colorScheme.surface,
                    ]
                  : [
                      const Color(0xFF90B7C2).withOpacity(0.2),
                      const Color(0xFFEACFCF).withOpacity(0.3),
                    ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            children: [
              Icon(
                Icons.account_circle_rounded,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.8),
              ),
              const SizedBox(height: 16),
              Text(
                t.user_header_title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Settings Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  t.section_account_info,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // User Email Card (Non-interactive)
              _buildInfoCard(
                context: context,
                icon: Icons.email_rounded,
                title: t.field_email,
                subtitle: email ?? '—',
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  t.section_settings,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Language
              _buildSettingCard(
                context: context,
                icon: Icons.language_rounded,
                title: t.setting_language,
                subtitle: context.watch<LocaleVM>().displayName(),
                onTap: () => _showLanguageSheet(context),
              ),
              const SizedBox(height: 12),

              // Theme
              _buildSettingCard(
                context: context,
                icon: Icons.brightness_6_rounded,
                title: t.setting_theme,
                // NEW: hiển thị theo ThemeVM
                subtitle: context.watch<ThemeVM>().displayName(context),
                onTap: () => _showThemeSheet(context), // NEW
              ),
              const SizedBox(height: 12),

              _buildSettingCard(
                context: context,
                icon: Icons.notifications_rounded,
                title: t.setting_notifications,
                subtitle: t.setting_notifications,
                onTap: () {
                  // TODO: mở trang cài đặt thông báo
                },
              ),
              const SizedBox(height: 12),

              _buildSettingCard(
                context: context,
                icon: Icons.privacy_tip_rounded,
                title: t.setting_privacy,
                subtitle: t.setting_privacy_title,
                onTap: () {
                  // TODO: mở trang quyền riêng tư
                },
              ),

              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  t.section_about,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              _buildSettingCard(
                context: context,
                icon: Icons.info_rounded,
                title: t.about_app_info,
                subtitle: t.about_version('1.0.0'),
                onTap: () {
                  // TODO: show app info
                },
              ),
              const SizedBox(height: 12),

              _buildSettingCard(
                context: context,
                icon: Icons.help_rounded,
                title: t.about_help,
                subtitle: '—',
                onTap: () {
                  // TODO: open help center
                },
              ),

              const SizedBox(height: 32),

              // Logout Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(t.logout_confirm_title),
                          content: Text(t.logout_confirm_msg),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(t.btn_cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text(t.btn_ok),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true && context.mounted) {
                        await context.read<AuthVM>().signOut();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            t.logout,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // Bottom sheet chọn ngôn ngữ
  Future<void> _showLanguageSheet(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(t.setting_language_vi),
              onTap: () {
                context.read<LocaleVM>().setLocale(const Locale('vi'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(t.setting_language_en),
              onTap: () {
                context.read<LocaleVM>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // NEW: Bottom sheet chọn theme
  Future<void> _showThemeSheet(BuildContext context) async {
    final themeVM = context.read<ThemeVM>();

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_suggest_rounded),
              title: Text(ctx.l10n.setting_theme_system),
              onTap: () {
                themeVM.setMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode_rounded),
              title: Text(
                ctx.l10n.setting_theme_light,
              ),
              onTap: () {
                themeVM.setMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_rounded),
              title: Text(
                // Nếu bạn đã có key i18n, thay thế bằng t.setting_theme_dark
                ctx.l10n.setting_theme_dark,
              ),
              onTap: () {
                themeVM.setMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Non-interactive info card for displaying user information
  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  // Interactive setting card with onTap functionality
  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
