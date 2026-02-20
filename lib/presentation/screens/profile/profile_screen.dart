import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';

/// Minimal profile screen.
///
/// Shows: display name, email, premium status, sign out button.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
              // Back
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                l10n.profileTitle,
                style: theme.textTheme.displayLarge,
              ),

              const SizedBox(height: AppSpacing.xxl),

              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      if (user.displayName != null &&
                          user.displayName!.isNotEmpty) ...[
                        Text(
                          user.displayName!,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Email
                      if (user.email != null && user.email!.isNotEmpty) ...[
                        Text(
                          user.email!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Premium status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                        child: Text(
                          user.isPremium
                              ? l10n.profilePremium
                              : l10n.profileFree,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Sign out
                      Center(
                        child: TextButton(
                          onPressed: () => _signOut(context, ref),
                          child: Text(
                            l10n.signOut,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => Text(
                  l10n.genericError,
                  style: theme.textTheme.bodySmall,
                ),
              ),
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
