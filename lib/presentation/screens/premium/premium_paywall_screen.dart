import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/login_screen.dart';
import 'package:kendin/presentation/screens/auth/verify_email_screen.dart';

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
    final isExpired = user?.membershipStatus == MembershipStatus.expired;

    return Scaffold(
      body: SafeArea(
        child: (isPremium || isExpired)
            ? _PremiumTimeline(userId: user!.id, isExpired: isExpired)
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

class _PremiumTimeline extends ConsumerStatefulWidget {
  const _PremiumTimeline({required this.userId, this.isExpired = false});
  final String userId;
  final bool isExpired;

  @override
  ConsumerState<_PremiumTimeline> createState() => _PremiumTimelineState();
}

class _PremiumTimelineState extends ConsumerState<_PremiumTimeline> {
  static const _pageSize = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final currentAsync = ref.watch(currentReflectionProvider);
    final archivedAsync = ref.watch(_archivedReflectionsProvider(widget.userId));

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

        // Expired banner
        if (widget.isExpired) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              children: [
                Text(
                  l10n.premiumExpiredBanner,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.premiumExpiredRenew,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 36,
                  child: FilledButton(
                    onPressed: () {
                      // Navigate to free paywall to renew
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const PremiumPaywallScreen(),
                        ),
                      );
                    },
                    child: Text(l10n.premiumRenewButton),
                  ),
                ),
              ],
            ),
          ),
        ],

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

              // Paginate
              final totalPages = (all.length / _pageSize).ceil();
              final start = _currentPage * _pageSize;
              final end = (start + _pageSize).clamp(0, all.length);
              final pageItems = all.sublist(start, end);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      itemCount: pageItems.length,
                      itemBuilder: (context, index) {
                        final reflection = pageItems[index];
                        return _TimelineItem(
                          reflection: reflection,
                          isLast: index == pageItems.length - 1,
                          onTap: () =>
                              _showReflectionModal(context, reflection),
                        );
                      },
                    ),
                  ),
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentPage > 0
                                ? () =>
                                    setState(() => _currentPage--)
                                : null,
                          ),
                          Text(
                            '${_currentPage + 1} / $totalPages',
                            style: theme.textTheme.bodySmall,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentPage < totalPages - 1
                                ? () =>
                                    setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
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

void _showReflectionModal(
  BuildContext context,
  WeeklyReflectionEntity reflection,
) {
  final theme = Theme.of(context);
  final locale = Localizations.localeOf(context);
  final weekLabel = KendinDateUtils.formatDate(
    reflection.weekStartDate,
    locale: locale,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                // Drag handle
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Week label
                Text(
                  weekLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Reflection content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: Text(
                        reflection.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

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

    final locale = Localizations.localeOf(context);
    final weekLabel = KendinDateUtils.formatDate(
      reflection.weekStartDate,
      locale: locale,
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
