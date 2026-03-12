import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/domain/entities/user_entity.dart';
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
/// Sections:
/// 1. Current User Info (ID, email, type, premium status)
/// 2. Cards: Derinlik, Dil, Hakkında, Admin (if admin)
/// 3. Login/Register (anonymous) or Logout (registered)
/// 3b. Delete Account (registered users only)
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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

              // ─── 1. Current User Section ─────────────────
              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  final name = user.isAnonymous ? null : user.displayName;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display name
                      Text(
                        (name != null && name.isNotEmpty) ? name : 'Kendin',
                        style: theme.textTheme.displayLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _membershipLabel(user.membershipStatus, l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: user.membershipStatus ==
                                  MembershipStatus.expired
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // User info card
                      _UserInfoCard(
                        userId: user.id,
                        email: user.email,
                        isAnonymous: user.isAnonymous,
                        isPremium: user.isPremium,
                        isAdmin: user.isAdmin,
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text(
                  l10n.genericError,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ─── 2. Cards ─────────────────────────────────

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

              const SizedBox(height: AppSpacing.xxl),

              // ─── 3. Login / Logout ────────────────────────
              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  final isAnon = user.isAnonymous;

                  if (isAnon) {
                    // Giriş Yap / Login button
                    return Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: AppSpacing.buttonHeight,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.buttonRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.menuLogin,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Çıkış Yap / Logout button (authenticated)
                  return Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => _signOut(context, ref),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.menuLogout,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ─── 3b. Delete Account ──────────────────────
              userAsync.when(
                data: (user) {
                  if (user == null || user.isAnonymous) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Center(
                      child: TextButton(
                        onPressed: () =>
                            _confirmDeleteAccount(context, ref, user.id),
                        child: Text(
                          l10n.menuDeleteAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
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

  String _membershipLabel(MembershipStatus status, AppLocalizations l10n) {
    switch (status) {
      case MembershipStatus.free:
        return l10n.membershipFree;
      case MembershipStatus.premium:
        return l10n.membershipPremium;
      case MembershipStatus.expired:
        return l10n.membershipExpired;
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.deleteAccountConfirmButton,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authServiceProvider).deleteAccount(userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeleted),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Re-initialize with anonymous session
        await ref.read(currentUserProvider.notifier).refresh();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(isRoot: true),
            ),
            (_) => false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(isRoot: true),
          ),
          (_) => false,
        );
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

// ─── User Info Card ──────────────────────────────────

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({
    required this.userId,
    required this.email,
    required this.isAnonymous,
    required this.isPremium,
    required this.isAdmin,
  });

  final String userId;
  final String? email;
  final bool isAnonymous;
  final bool isPremium;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity( 0.2)
                : AppColors.lightDivider.withOpacity( 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User ID with copy button
          _InfoRow(
            label: l10n.menuUserId,
            value: userId.length > 16
                ? '${userId.substring(0, 8)}...${userId.substring(userId.length - 4)}'
                : userId,
            trailing: IconButton(
              icon: Icon(
                Icons.copy,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: userId));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.menuCopied),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),

          const Divider(height: AppSpacing.md),

          // Email
          _InfoRow(
            label: l10n.menuUserEmail,
            value: email ?? '-',
          ),

          const Divider(height: AppSpacing.md),

          // Account type
          _InfoRow(
            label: l10n.menuUserType,
            value: isAnonymous
                ? l10n.menuUserTypeAnonymous
                : l10n.menuUserTypeRegistered,
          ),

          const Divider(height: AppSpacing.md),

          // Membership status
          _InfoRow(
            label: l10n.menuUserPremiumStatus,
            value: isPremium ? l10n.membershipPremium : l10n.membershipFree,
            valueColor: isPremium ? theme.colorScheme.primary : null,
          ),

          // Admin badge
          if (isAdmin) ...[
            const Divider(height: AppSpacing.md),
            _InfoRow(
              label: 'Admin',
              value: '✓',
              valueColor: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.xs),
          trailing!,
        ],
      ],
    );
  }
}

// ─── Menu Card ──────────────────────────────────────

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
                  ? Colors.black.withOpacity( 0.2)
                  : AppColors.lightDivider.withOpacity( 0.5),
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
