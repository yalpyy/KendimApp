import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/account_gate_screen.dart';
import 'package:kendin/presentation/screens/premium/premium_paywall_screen.dart';

/// Settings screen.
///
/// Provides:
/// - Account creation (anonymous users → AccountGateScreen)
/// - Premium subscription ("Derinlik" → PremiumPaywallScreen)
/// - Restore purchases
/// - Sign out (for non-anonymous users)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

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
                AppStrings.settings,
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: AppSpacing.xxl),

              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Create account (only for anonymous users)
                      if (user.isAnonymous) ...[
                        _SettingsTile(
                          title: AppStrings.createAccount,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AccountGateScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Premium
                      if (!user.isPremium) ...[
                        _SettingsTile(
                          title: AppStrings.premium,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PremiumPaywallScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                      ] else ...[
                        Text(
                          AppStrings.premium,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Restore purchases
                      _SettingsTile(
                        title: AppStrings.restorePurchase,
                        onTap: () => _restorePurchases(context, ref),
                      ),

                      // Sign out (only for non-anonymous users)
                      if (!user.isAnonymous) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                        _SettingsTile(
                          title: AppStrings.signOut,
                          onTap: () => _signOut(context, ref),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => Text(
                  AppStrings.genericError,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(premiumServiceProvider).restorePurchases();
      await ref.read(currentUserProvider.notifier).refresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authServiceProvider).signOut();
      // Re-initialize with anonymous user.
      final user = await ref.read(authServiceProvider).initialize();
      ref.read(currentUserProvider.notifier).setUser(user);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
