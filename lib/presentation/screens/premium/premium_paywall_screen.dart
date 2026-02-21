import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/login_screen.dart';
import 'package:kendin/presentation/screens/auth/verify_email_screen.dart';
import 'package:kendin/presentation/screens/reflection/reflection_screen.dart';

/// Derinlik screen.
///
/// FREE user: explanation, advantages, prices, "Derinliği Aç" button.
/// PREMIUM user: vertical minimalist timeline of weekly reflections.
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
    final isPremium = user?.isPremium ?? false;

    return Scaffold(
      body: SafeArea(
        child: isPremium
            ? _PremiumTimeline(userId: user!.id)
            : _FreePaywall(
                isLoading: _isLoading,
                onPurchase: (plan) => _purchase(plan),
                onRestore: () => _restorePurchases(),
              ),
      ),
    );
  }

  Future<void> _purchase(String plan) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Auth gate: anonymous → login
    if (user.isAnonymous) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Auth gate: email not verified
    if (!user.emailVerified) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
      return;
    }

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

// ─── Free User Paywall ─────────────────────────────

class _FreePaywall extends StatelessWidget {
  const _FreePaywall({
    required this.isLoading,
    required this.onPurchase,
    required this.onRestore,
  });

  final bool isLoading;
  final void Function(String plan) onPurchase;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
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
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Title
                Text(
                  l10n.premiumTitle,
                  style: theme.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Explanation
                Text(
                  l10n.premiumExplanation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Advantages
                _Advantage(text: l10n.premiumAdvantage1),
                const SizedBox(height: AppSpacing.sm),
                _Advantage(text: l10n.premiumAdvantage2),
                const SizedBox(height: AppSpacing.sm),
                _Advantage(text: l10n.premiumAdvantage3),

                const SizedBox(height: AppSpacing.xxl),

                // Prices
                _PlanButton(
                  label: l10n.premiumMonthly,
                  isLoading: isLoading,
                  onPressed: () => onPurchase('monthly'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PlanButton(
                  label: l10n.premiumYearly,
                  subtitle: l10n.premiumYearlySave,
                  isLoading: isLoading,
                  onPressed: () => onPurchase('yearly'),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Restore
                TextButton(
                  onPressed: onRestore,
                  child: Text(l10n.premiumRestore),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Advantage extends StatelessWidget {
  const _Advantage({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
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

// ─── Premium User Timeline ─────────────────────────

class _PremiumTimeline extends ConsumerWidget {
  const _PremiumTimeline({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final currentAsync = ref.watch(currentReflectionProvider);
    final archivedAsync = ref.watch(_archivedReflectionsProvider(userId));

    return Column(
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
                l10n.premiumTimelineTitle,
                style: theme.textTheme.displayLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: archivedAsync.when(
            data: (archived) {
              final current = currentAsync.valueOrNull;
              final all = <WeeklyReflectionEntity>[
                if (current != null) current,
                ...archived,
              ];

              if (all.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Text(
                      l10n.premiumNoReflections,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: all.length,
                itemBuilder: (context, index) {
                  final reflection = all[index];
                  return _TimelineItem(
                    reflection: reflection,
                    isLast: index == all.length - 1,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReflectionScreen(),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(l10n.genericError, style: theme.textTheme.bodySmall),
            ),
          ),
        ),
      ],
    );
  }
}

final _archivedReflectionsProvider =
    FutureProvider.autoDispose.family<List<WeeklyReflectionEntity>, String>(
  (ref, userId) =>
      ref.read(reflectionServiceProvider).getArchivedReflections(userId),
);

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.reflection,
    required this.isLast,
    required this.onTap,
  });

  final WeeklyReflectionEntity reflection;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final dotColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final weekLabel = KendinDateUtils.formatDateTurkish(
      reflection.weekStartDate,
    );
    final preview = reflection.content.length > 80
        ? '${reflection.content.substring(0, 80)}...'
        : reflection.content;

    return IntrinsicHeight(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line + dot
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 1, color: lineColor),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      preview,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
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
