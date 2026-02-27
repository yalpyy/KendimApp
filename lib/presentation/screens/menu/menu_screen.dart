import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';
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
/// 4. Debug section (expandable — raw session, token expiry, metadata)
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
                        user.isPremium
                            ? l10n.profilePremium
                            : l10n.profileFree,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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

              const SizedBox(height: AppSpacing.xxl),

              // ─── 4. Debug Section (expandable) ────────────
              const _DebugSection(),

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
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.lightDivider.withValues(alpha: 0.5),
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

          // Premium status
          _InfoRow(
            label: l10n.menuUserPremiumStatus,
            value: isPremium ? l10n.profilePremium : l10n.profileFree,
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

// ─── Debug Section ──────────────────────────────────

class _DebugSection extends StatefulWidget {
  const _DebugSection();

  @override
  State<_DebugSection> createState() => _DebugSectionState();
}

class _DebugSectionState extends State<_DebugSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Session? session;
    try {
      session = SupabaseClientSetup.client.auth.currentSession;
    } catch (_) {
      session = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            children: [
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.menuDebugTitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.md),

          if (session == null)
            Text(
              l10n.menuDebugNoSession,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            // Token expiry
            _DebugField(
              label: l10n.menuDebugTokenExpiry,
              value: session.expiresAt != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      session.expiresAt! * 1000,
                    ).toIso8601String()
                  : '-',
            ),

            const SizedBox(height: AppSpacing.sm),

            // User metadata
            _DebugField(
              label: l10n.menuDebugMetadata,
              value: _prettyJson(session.user.userMetadata),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Raw session JSON
            _DebugField(
              label: l10n.menuDebugSession,
              value: _sessionSummary(session),
            ),
          ],
        ],
      ],
    );
  }

  String _prettyJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return '{}';
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _sessionSummary(Session session) {
    final summary = {
      'user_id': session.user.id,
      'email': session.user.email,
      'is_anonymous': session.user.userMetadata?['is_anonymous'],
      'expires_at': session.expiresAt,
      'token_type': session.tokenType,
      'provider_token': session.providerToken != null ? '***' : null,
      'created_at': session.user.createdAt,
    };
    try {
      return const JsonEncoder.withIndent('  ').convert(summary);
    } catch (_) {
      return summary.toString();
    }
  }
}

class _DebugField extends StatelessWidget {
  const _DebugField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: SelectableText(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ),
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
