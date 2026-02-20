import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/login_screen.dart';
import 'package:kendin/presentation/screens/auth/verify_email_screen.dart';

/// Premium paywall screen ("Derinlik").
///
/// Shows advantages, 49₺/month and 299₺/year options.
/// Auth gates:
/// - Anonymous → LoginScreen
/// - Unverified email → VerifyEmailScreen
/// - Verified → purchase
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
                  l10n.premiumTitle,
                  style: theme.textTheme.displayLarge,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Benefits
              Center(
                child: Text(
                  l10n.premiumSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Auth gate: anonymous
              if (isAnonymous)
                _buildAuthGate(context, l10n)
              // Auth gate: email not verified
              else if (!emailVerified)
                _buildVerifyGate(context, l10n)
              // Purchase options
              else ...[
                _PlanButton(
                  label: l10n.premiumMonthly,
                  isLoading: _isLoading,
                  onPressed: () => _purchase('monthly'),
                ),

                const SizedBox(height: AppSpacing.sm),

                _PlanButton(
                  label: l10n.premiumYearly,
                  subtitle: l10n.premiumYearlySave,
                  isLoading: _isLoading,
                  onPressed: () => _purchase('yearly'),
                ),

                const SizedBox(height: AppSpacing.xl),

                Center(
                  child: TextButton(
                    onPressed: () => _restorePurchases(),
                    child: Text(l10n.premiumRestore),
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

  Widget _buildAuthGate(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Text(
            l10n.menuAccountSubtitleAnon,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: Text(l10n.createAccount),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyGate(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Text(
            l10n.verifyFirst,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
            ),
            child: Text(l10n.verifyEmailTitle),
          ),
        ),
      ],
    );
  }

  Future<void> _purchase(String plan) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(premiumServiceProvider).purchase(plan);
      await ref.read(currentUserProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).genericError),
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
          SnackBar(
            content: Text(AppLocalizations.of(context).genericError),
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
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.outline),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
