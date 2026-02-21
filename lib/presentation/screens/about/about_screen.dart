import 'package:flutter/material.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/screens/legal/privacy_policy_screen.dart';
import 'package:kendin/presentation/screens/legal/terms_of_service_screen.dart';
import 'package:kendin/presentation/screens/legal/kvkk_screen.dart';

/// About screen — calm, honest, minimal.
///
/// Sections: Amaç, Farkındalık, Haftalık Yansıma, Derinlik.
/// Links to legal pages at bottom.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.screenVertical),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.aboutTitle,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: l10n.aboutPurposeTitle,
                      body: l10n.aboutPurposeBody,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      title: l10n.aboutAwarenessTitle,
                      body: l10n.aboutAwarenessBody,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      title: l10n.aboutReflectionTitle,
                      body: l10n.aboutReflectionBody,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      title: l10n.aboutPremiumTitle,
                      body: l10n.aboutPremiumBody,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Legal links
                    Divider(color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: AppSpacing.md),
                    _LegalLink(
                      label: l10n.privacyPolicy,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _LegalLink(
                      label: l10n.termsOfService,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      ),
                    ),
                    _LegalLink(
                      label: l10n.kvkkNotice,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const KvkkScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
