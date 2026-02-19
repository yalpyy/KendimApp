import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/usecases/strike_manager.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/reflection/reflection_screen.dart';
import 'package:kendin/presentation/screens/settings/settings_screen.dart';
import 'package:kendin/presentation/widgets/date_header.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';
import 'package:kendin/presentation/widgets/kendin_text_field.dart';
import 'package:kendin/presentation/widgets/strike_indicator.dart';

/// The single main screen of Kendin.
///
/// Layout (top to bottom):
/// - Menu icon (top-right)
/// - Date header
/// - Strike indicator
/// - Main question (centered)
/// - Text field
/// - "Yazdım" button
///
/// On Sunday: shows "Bu haftayı gör" instead.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _textController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasWrittenToday = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final strikeAsync = ref.watch(strikeStateProvider);
    final todayEntryAsync = ref.watch(todayEntryProvider);
    final isSunday = KendinDateUtils.isSunday(DateTime.now());

    // Check if already written today.
    todayEntryAsync.whenData((entry) {
      if (entry != null && !_hasWrittenToday) {
        setState(() {
          _hasWrittenToday = true;
          _textController.text = entry.text;
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            children: [
              // Top bar
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Balance the icon
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () => _openSettings(context),
                    tooltip: AppStrings.settings,
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Date
              const DateHeader(),
              const SizedBox(height: AppSpacing.sm),

              // Strike indicator
              strikeAsync.when(
                data: (strike) {
                  if (strike == null) {
                    return const SizedBox.shrink();
                  }
                  return StrikeIndicator(
                    completedDays: strike.completedDays,
                    daysWithEntries: strike.daysWithEntries,
                  );
                },
                loading: () => const SizedBox(height: AppSpacing.strikeDotSize),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Main question
              Text(
                isSunday
                    ? AppStrings.seeThisWeek
                    : AppStrings.mainQuestion,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Content area
              if (isSunday)
                _buildSundayContent(context)
              else
                _buildWritingContent(context),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWritingContent(BuildContext context) {
    return Column(
      children: [
        KendinTextField(
          controller: _textController,
          enabled: !_hasWrittenToday,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!_hasWrittenToday)
          KendinButton(
            label: AppStrings.writeButton,
            isLoading: _isSubmitting,
            onPressed: _textController.text.trim().isEmpty
                ? null
                : () => _submitEntry(),
          )
        else
          Text(
            AppStrings.writeButton,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
      ],
    );
  }

  Widget _buildSundayContent(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final strikeAsync = ref.watch(strikeStateProvider);

    return strikeAsync.when(
      data: (strike) {
        if (strike == null) return const SizedBox.shrink();

        return Column(
          children: [
            // Show strike summary
            Text(
              '${strike.completedDays}/${strike.totalDays}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // If week is complete or user can use tokens
            KendinButton(
              label: AppStrings.seeThisWeek,
              isLoading: _isSubmitting,
              onPressed: () => _triggerReflection(context, strike),
            ),

            // If not complete and premium, show miss token option
            if (!strike.isWeekComplete)
              userAsync.when(
                data: (user) {
                  if (user == null || !user.isPremium) {
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Text(
                        AppStrings.reflectionLocked,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: TextButton(
                      onPressed: () => _useMissTokens(),
                      child: Text(
                        '${AppStrings.completeMissingDay} '
                        '(${AppStrings.missTokensRemaining}: '
                        '${user.premiumMissTokens})',
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => Text(
        AppStrings.genericError,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Future<void> _submitEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(entryDatasourceProvider).createEntry(user.id, text);
      setState(() {
        _hasWrittenToday = true;
        _isSubmitting = false;
      });
      // Refresh strike state.
      ref.invalidate(strikeStateProvider);
      ref.invalidate(todayEntryProvider);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _triggerReflection(
    BuildContext context,
    StrikeState strike,
  ) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Check eligibility.
    if (!strike.isWeekComplete && !user.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.reflectionLocked),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final triggered =
          await ref.read(reflectionServiceProvider).triggerReflection(user);

      setState(() => _isSubmitting = false);

      if (triggered && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ReflectionScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _useMissTokens() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    try {
      final newTokens =
          await ref.read(strikeManagerProvider).useMissTokens(user);
      ref.read(currentUserProvider.notifier).setUser(
            user.copyWith(premiumMissTokens: newTokens),
          );
      ref.invalidate(strikeStateProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}
