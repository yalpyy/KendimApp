import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/premium/premium_screen.dart';
import 'package:kendin/presentation/screens/settings/link_account_sheet.dart';

/// Settings screen.
///
/// Provides:
/// - Account linking ("Verilerimi güvenceye al")
/// - Premium subscription ("Derinlik")
/// - Restore purchases
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

              // Account linking
              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Link account (only for anonymous users)
                      if (user.isAnonymous) ...[
                        _SettingsTile(
                          title: AppStrings.secureData,
                          onTap: () => _showLinkSheet(context),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Premium
                      if (!user.isPremium) ...[
                        _SettingsTile(
                          title: AppStrings.premium,
                          onTap: () => _openPremium(context),
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

  void _showLinkSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (_) => const LinkAccountSheet(),
    );
  }

  void _openPremium(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(premiumServiceProvider).restorePurchases();
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
