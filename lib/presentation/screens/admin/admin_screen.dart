import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/screens/admin/admin_notifications_screen.dart';
import 'package:kendin/presentation/screens/admin/admin_reflections_screen.dart';
import 'package:kendin/presentation/screens/admin/admin_stats_screen.dart';
import 'package:kendin/presentation/screens/admin/admin_users_screen.dart';

/// Admin panel hub — navigation to sub-pages.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.screenVertical),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.adminTitle,
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Menu cards
              _AdminMenuCard(
                icon: Icons.bar_chart,
                title: l10n.adminTabStats,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminStatsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _AdminMenuCard(
                icon: Icons.people,
                title: l10n.adminTabUsers,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _AdminMenuCard(
                icon: Icons.notifications,
                title: l10n.adminTabNotifications,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminNotificationsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _AdminMenuCard(
                icon: Icons.auto_stories,
                title: l10n.adminTabReflections,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminReflectionsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : AppColors.lightDivider.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
