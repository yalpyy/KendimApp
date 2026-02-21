import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/about/about_screen.dart';
import 'package:kendin/presentation/screens/auth/login_screen.dart';
import 'package:kendin/presentation/screens/language/language_screen.dart';
import 'package:kendin/presentation/screens/premium/premium_paywall_screen.dart';
import 'package:kendin/presentation/screens/profile/profile_screen.dart';

/// Card-based menu screen.
///
/// Top section: username (large) + account status.
/// Cards: Derinlik, Hesap, Dil, Hakkında.
/// Minimal, rounded, soft shadow, calm.
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

              // Cards
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

              // Account card — depends on auth state
              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  final isAnon = user.isAnonymous;
                  return _MenuCard(
                    title: l10n.menuAccountTitle,
                    subtitle: isAnon
                        ? l10n.menuAccountSubtitleAnon
                        : l10n.menuAccountSubtitleAuth,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => isAnon
                            ? const LoginScreen()
                            : const ProfileScreen(),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.md),

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

              _MenuCard(
                title: l10n.menuAboutTitle,
                subtitle: 'Kendin',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AboutScreen(),
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
              // ignore: deprecated_member_use
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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
