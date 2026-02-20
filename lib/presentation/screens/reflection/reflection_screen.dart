import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/premium/premium_paywall_screen.dart';

/// Displays the weekly reflection.
///
/// Shows a loading state initially, then polls until the reflection is ready.
///
/// After the reflection is shown:
/// - Free users see a premium CTA
/// - Premium users see the archive button
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  bool _isPolling = true;
  String? _reflectionContent;
  String? _reflectionId;

  @override
  void initState() {
    super.initState();
    _pollForReflection();
  }

  Future<void> _pollForReflection() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Poll every 30 seconds for up to 15 minutes.
    for (var i = 0; i < 30; i++) {
      if (!mounted) return;

      final reflection =
          await ref.read(reflectionServiceProvider).getCurrentReflection(
                user.id,
              );

      if (reflection != null) {
        setState(() {
          _reflectionContent = reflection.content;
          _reflectionId = reflection.id;
          _isPolling = false;
        });
        return;
      }

      await Future.delayed(const Duration(seconds: 30));
    }

    // Timeout — still show waiting message.
    if (mounted) {
      setState(() => _isPolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isPremium = user?.isPremium ?? false;

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

              const Spacer(flex: 2),

              if (_isPolling)
                // Loading state
                Center(
                  child: Text(
                    l10n.reflectionLoading,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              else if (_reflectionContent != null)
                // Reflection content
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Text(
                        _reflectionContent!,
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  height: 1.8,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                // Not ready yet
                Center(
                  child: Text(
                    l10n.reflectionNotReady,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

              if (!_isPolling && _reflectionContent != null) ...[
                const SizedBox(height: AppSpacing.xl),

                // Premium CTA for free users
                if (!isPremium) _buildPremiumCta(context, l10n),

                // Archive button for premium users
                if (isPremium)
                  Center(
                    child: TextButton(
                      onPressed: () => _archive(),
                      child: Text(l10n.archive),
                    ),
                  ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCta(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Strong CTA text
        Text(
          l10n.premiumCtaStrong,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        // CTA button
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PremiumPaywallScreen(),
              ),
            ),
            child: Text(
              '${l10n.premiumTitle} — ${l10n.premiumMonthlyPrice}',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _archive() async {
    if (_reflectionId == null) return;

    final l10n = AppLocalizations.of(context);

    try {
      await ref
          .read(reflectionServiceProvider)
          .archiveReflection(_reflectionId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.archived),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
