import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/about/about_screen.dart';
import 'package:kendin/presentation/screens/admin/admin_screen.dart';
import 'package:kendin/presentation/screens/auth/login_screen.dart';
import 'package:kendin/presentation/screens/language/language_screen.dart';
import 'package:kendin/presentation/screens/premium/premium_paywall_screen.dart';

/// Settings / Menu screen.
///
/// Cards: Derinlik, Dil, Hakkında.
/// Bottom: Giriş Yap / Çıkış Yap.
/// Admin users also see "Admin Paneli" card.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: AppSpacing.xl),

              // User name + account status
              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  final name = user.isAnonymous ? null : user.displayName;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (name != null && name.isNotEmpty)
                            ? name
                            : 'Kendin',
                        style: theme.textTheme.displayLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.isPremium
                            ? l10n.profilePremium
                            : l10n.profileFree,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ─── Cards ─────────────────────────────────

              // Derinlik
              _MenuCard(
                title: l10n.menuPremiumTitle,
                subtitle: l10n.menuPremiumSubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PremiumPaywallScreen(),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Dil
              _MenuCard(
                title: l10n.menuLanguageTitle,
                subtitle: Localizations.localeOf(context).languageCode == 'tr'
                    ? 'Türkçe'
                    : 'English',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LanguageScreen(),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Hakkında
              _MenuCard(
                title: l10n.menuAboutTitle,
                subtitle: 'Kendin',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AboutScreen(),
                  ),
                ),
              ),

              // Admin Paneli — only for admin users
              userAsync.when(
                data: (user) {
                  if (user == null || !user.isAdmin) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: _MenuCard(
                      title: l10n.menuAdmin,
                      subtitle: '',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminScreen(),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const Spacer(),

              // ─── Bottom: Giriş Yap / Çıkış Yap ─────────
              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  final isAnon = user.isAnonymous;

                  if (isAnon) {
                    // Giriş Yap
                    return Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: Text(
                          l10n.menuLogin,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  // Çıkış Yap (authenticated)
                  return Center(
                    child: TextButton(
                      onPressed: () => _signOut(context, ref),
                      child: Text(
                        l10n.menuLogout,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authServiceProvider).signOut();
      final user = await ref.read(authServiceProvider).initialize();
      ref.read(currentUserProvider.notifier).setUser(user);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.lightDivider.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
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
