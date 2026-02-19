import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';

/// Premium subscription screen ("Derinlik").
///
/// Shows monthly and yearly plans.
/// Purchase requires a linked (non-anonymous) account.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final premiumService = ref.read(premiumServiceProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAnonymous = user?.isAnonymous ?? true;

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
                  AppStrings.premium,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Benefits
              Center(
                child: Text(
                  'Eksik günleri tamamla.\n'
                  'Yansımalarını arşivle.\n'
                  'Daha derin bir bakış.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Account warning for anonymous users
              if (isAnonymous)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Text(
                    'Satın almak için önce hesabını güvenceye al.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),

              if (!isAnonymous) ...[
                // Monthly plan
                for (final product in premiumService.products)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _purchase(product),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                Theme.of(context).colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          '${product.title} — ${product.price}',
                        ),
                      ),
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

  Future<void> _purchase(dynamic product) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(premiumServiceProvider).purchase(product);
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
}
