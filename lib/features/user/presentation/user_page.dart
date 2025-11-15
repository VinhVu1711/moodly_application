import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
// import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:provider/provider.dart';

import 'package:moodlyy_application/features/auth/vm/auth_vm.dart';
// i18n
// import 'package:moodlyy_application/l10n/app_localizations.dart';

// Locale Provider
// import 'package:moodlyy_application/features/app/vm/locale_vm.dart';
// // Theme Provider
// import 'package:moodlyy_application/features/app/vm/theme_vm.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                context.l10n.user_header_title,
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
                  context.l10n.section_account_info,
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
                title: context.l10n.field_email,
                subtitle: email ?? '—',
              ),

              const SizedBox(height: 24),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              //   child: Text(
              //     t.section_settings,
              //     style: theme.textTheme.titleSmall?.copyWith(
              //       color: theme.colorScheme.primary,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 8),

              // Current Settings Display Section
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(16),
              //     border: Border.all(
              //       color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              //       width: 1,
              //     ),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Icon(
              //             Icons.settings_rounded,
              //             color: theme.colorScheme.primary,
              //             size: 20,
              //           ),
              //           const SizedBox(width: 8),
              //           Text(
              //             'Current Settings',
              //             style: theme.textTheme.titleSmall?.copyWith(
              //               color: theme.colorScheme.primary,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 12),
              //       Row(
              //         children: [
              //           Expanded(
              //             child: _buildCurrentSettingChip(
              //               context: context,
              //               icon: Icons.language_rounded,
              //               label: context.watch<LocaleVM>().displayName(),
              //               color: theme.colorScheme.primaryContainer,
              //             ),
              //           ),
              //           const SizedBox(width: 8),
              //           Expanded(
              //             child: _buildCurrentSettingChip(
              //               context: context,
              //               icon: Icons.brightness_6_rounded,
              //               label: context.watch<ThemeVM>().displayName(context),
              //               color: theme.colorScheme.secondaryContainer,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),

              // const SizedBox(height: 24),

              // Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  context.l10n.section_settings,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Settings
              _buildSettingCard(
                context: context,
                icon: Icons.settings_rounded,
                title: context.l10n.section_settings,
                subtitle: context.l10n.theme_language,
                onTap: () => context.push('/settings'),
              ),
              const SizedBox(height: 12),

              // Privacy
              _buildSettingCard(
                context: context,
                icon: Icons.privacy_tip_rounded,
                title: context.l10n.setting_privacy,
                subtitle: context.l10n.setting_privacy_title,
                onTap: () => context.push('/privacy'),
              ),

              const SizedBox(height: 24),

              // About Section
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              //   child: Text(
              //     context.l10n.section_about,
              //     style: theme.textTheme.titleSmall?.copyWith(
              //       color: theme.colorScheme.primary,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 8),

              // _buildSettingCard(
              //   context: context,
              //   icon: Icons.info_rounded,
              //   title: context.l10n.about_app_info,
              //   subtitle: context.l10n.about_version('1.0.0'),
              //   onTap: () => context.push('/about'),
              // ),
              // const SizedBox(height: 12),

              // _buildSettingCard(
              //   context: context,
              //   icon: Icons.help_rounded,
              //   title: context.l10n.about_help,
              //   subtitle: 'Support & Help',
              //   onTap: () => context.push('/about'),
              // ),

              // const SizedBox(height: 32),

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
                          title: Text(context.l10n.logout_confirm_title),
                          content: Text(context.l10n.logout_confirm_msg),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.l10n.btn_cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text(context.l10n.btn_ok),
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
                            context.l10n.logout,
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

  // Widget _buildCurrentSettingChip({
  //   required BuildContext context,
  //   required IconData icon,
  //   required String label,
  //   required Color color,
  // }) {
  //   final theme = Theme.of(context);
  //   final colorScheme = theme.colorScheme;

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.3),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: colorScheme.outlineVariant.withOpacity(0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(
  //           icon,
  //           size: 16,
  //           color: colorScheme.primary,
  //         ),
  //         const SizedBox(width: 6),
  //         Flexible(
  //           child: Text(
  //             label,
  //             style: theme.textTheme.bodySmall?.copyWith(
  //               color: colorScheme.primary,
  //               fontWeight: FontWeight.w500,
  //             ),
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // NEW: Bottom sheet cài đặt Notification (Quote 08:00, Streak 20:00)
  // Future<void> _showNotificationSheet(BuildContext context) async {
  //   final auth = context.read<AuthVM>();
  //   final uid = auth.user?.id;

  //   if (uid == null) {
  //     // Không thay đổi UI tổng thể: chỉ báo nhanh nếu chưa đăng nhập (edge case)
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: const Text('')),
  //     );
  //     return;
  //   }

  //   final notifVM = context.read<NotificationVM>();
  //   bool quote = notifVM.notifQuote;
  //   bool streak = notifVM.notifStreak;

  //   await showModalBottomSheet(
  //     context: context,
  //     showDragHandle: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (ctx) => SafeArea(
  //       child: StatefulBuilder(
  //         builder: (ctx, setState) {
  //           return Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               SwitchListTile.adaptive(
  //                 contentPadding: const EdgeInsets.symmetric(
  //                   horizontal: 16,
  //                   vertical: 0,
  //                 ),
  //                 secondary: const Icon(Icons.format_quote_rounded),
  //                 title: const Text('Daily quote (08:00)'),
  //                 subtitle: const Text(
  //                   "Don't forget to check your quote today!",
  //                 ),
  //                 value: quote,
  //                 onChanged: (v) async {
  //                   setState(() => quote = v);
  //                   await notifVM.toggleQuote(uid, v);
  //                 },
  //               ),
  //               SwitchListTile.adaptive(
  //                 contentPadding: const EdgeInsets.symmetric(
  //                   horizontal: 16,
  //                   vertical: 0,
  //                 ),
  //                 secondary: const Icon(Icons.local_fire_department_rounded),
  //                 title: const Text('Keep streak (20:00)'),
  //                 subtitle: const Text("Keep your streak now! Don't lose it"),
  //                 value: streak,
  //                 onChanged: (v) async {
  //                   setState(() => streak = v);
  //                   await notifVM.toggleStreak(uid, v);
  //                 },
  //               ),
  //               const SizedBox(height: 8),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

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
