import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/account_gate_screen.dart';
import 'package:kendin/presentation/screens/auth/verify_email_screen.dart';

/// Premium paywall screen ("Derinlik").
///
/// Shows 49₺/month and 299₺/year options.
/// Requires a verified email account to purchase:
/// - Anonymous → AccountGateScreen
/// - Unverified email → VerifyEmailScreen
/// - Verified → proceed to purchase
class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAnonymous = user?.isAnonymous ?? true;
    final emailVerified = user?.emailVerified ?? false;

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
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),

              const Spacer(flex: 2),

              // Title
              Center(
                child: Text(
                  AppStrings.premiumTitle,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Benefits
              Center(
                child: Text(
                  AppStrings.premiumSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Account gate warning for anonymous users
              if (isAnonymous)
                _buildAccountGateWarning(context)
              // Email verification warning
              else if (!emailVerified)
                _buildVerifyEmailWarning(context)
              // Purchase options
              else ...[
                // Monthly plan
                _PlanButton(
                  label: '${AppStrings.premiumMonthly} — ${AppStrings.premiumMonthlyPrice}',
                  isLoading: _isLoading,
                  onPressed: () => _purchase('monthly'),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Yearly plan
                _PlanButton(
                  label: '${AppStrings.premiumYearly} — ${AppStrings.premiumYearlyPrice}',
                  subtitle: AppStrings.premiumYearlySave,
                  isLoading: _isLoading,
                  onPressed: () => _purchase('yearly'),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Restore purchases
                Center(
                  child: TextButton(
                    onPressed: () => _restorePurchases(),
                    child: const Text(AppStrings.restorePurchase),
                  ),
                ),
              ],

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountGateWarning(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Text(
            AppStrings.accountGateSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AccountGateScreen(),
              ),
            ),
            child: const Text(AppStrings.createAccount),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyEmailWarning(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Text(
            AppStrings.verifyEmailFirst,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const VerifyEmailScreen(),
              ),
            ),
            child: const Text(AppStrings.verifyEmailTitle),
          ),
        ),
      ],
    );
  }

  Future<void> _purchase(String plan) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(premiumServiceProvider).purchase(plan);
      // Refresh user state after purchase.
      await ref.read(currentUserProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await ref.read(premiumServiceProvider).restorePurchases();
      await ref.read(currentUserProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
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

class _PlanButton extends StatelessWidget {
  const _PlanButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (subtitle != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
