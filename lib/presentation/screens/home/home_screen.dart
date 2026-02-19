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

/// Whether the user is currently writing or has completed today's entry.
enum DayState {
  editing,
  completed,
}

/// The single main screen of Kendin.
///
/// On load: checks if today's entry exists.
///   - If exists → completed state ("Bugün kendindesin." + strike dots + "Güne ekle")
///   - If not   → editing state (question + text field + "Yazdım")
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

  /// null = not yet determined (waiting for todayEntry to load).
  DayState? _dayState;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  /// Triggers rebuild so Yazdım button enables/disables based on text.
  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final strikeAsync = ref.watch(strikeStateProvider);
    ref.watch(todayEntryProvider);
    final isSunday = KendinDateUtils.isSunday(DateTime.now());

    // Determine initial DayState from today's entry (once).
    ref.listen(todayEntryProvider, (previous, next) {
      if (!_initialized) {
        next.whenData((entry) {
          _initialized = true;
          final newState =
              entry != null ? DayState.completed : DayState.editing;
          debugPrint('[HomeScreen] Initial state: $newState');
          setState(() => _dayState = newState);
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

              // ── Sunday flow ──
              if (isSunday) ...[
                _buildStrikeRow(strikeAsync),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  AppStrings.seeThisWeek,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSundayContent(context),
              ]

              // ── Loading (DayState not yet resolved) ──
              else if (_dayState == null) ...[
                const SizedBox(height: AppSpacing.xxl),
                const CircularProgressIndicator(),
              ]

              // ── Completed state ──
              else if (_dayState == DayState.completed) ...[
                const SizedBox(height: AppSpacing.xxl),
                _buildCompletedContent(context, strikeAsync),
              ]

              // ── Editing state ──
              else ...[
                _buildStrikeRow(strikeAsync),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  AppStrings.mainQuestion,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildEditingContent(context),
              ],

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Strike row (reused in editing + sunday) ───────

  Widget _buildStrikeRow(AsyncValue<StrikeState?> strikeAsync) {
    return strikeAsync.when(
      data: (strike) {
        if (strike == null) return const SizedBox.shrink();
        return StrikeIndicator(
          completedDays: strike.completedDays,
          daysWithEntries: strike.daysWithEntries,
        );
      },
      loading: () => const SizedBox(height: AppSpacing.strikeDotSize),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── Editing State ─────────────────────────────────

  Widget _buildEditingContent(BuildContext context) {
    return Column(
      children: [
        KendinTextField(
          controller: _textController,
          enabled: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        KendinButton(
          label: AppStrings.writeButton,
          isLoading: _isSubmitting,
          onPressed: _textController.text.trim().isEmpty
              ? null
              : () => _submitEntry(),
        ),
      ],
    );
  }

  // ─── Completed State ───────────────────────────────

  Widget _buildCompletedContent(
    BuildContext context,
    AsyncValue<StrikeState?> strikeAsync,
  ) {
    return Column(
      children: [
        // "Bugün kendindesin."
        Text(
          AppStrings.dayCompleted,
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Strike dots (today's dot is filled)
        _buildStrikeRow(strikeAsync),
        const SizedBox(height: AppSpacing.lg),

        // "Güne ekle" button
        KendinButton(
          label: AppStrings.addToDay,
          onPressed: () => _onGuneEkle(),
        ),
      ],
    );
  }

  // ─── Sunday State ──────────────────────────────────

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

  // ─── Actions ───────────────────────────────────────

  /// "Yazdım" — save or update today's entry, switch to completed.
  Future<void> _submitEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(entryServiceProvider)
          .saveOrUpdateTodayEntry(user.id, text);
      debugPrint('[HomeScreen] Entry saved successfully');

      _textController.clear();
      setState(() {
        _dayState = DayState.completed;
        _isSubmitting = false;
      });
      debugPrint('[HomeScreen] State → completed');

      // Refresh strike state and today entry.
      ref.invalidate(strikeStateProvider);
      ref.invalidate(todayEntryProvider);
    } catch (e) {
      debugPrint('[HomeScreen] Error saving entry: $e');
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

  /// "Güne ekle" — fetch today's entry, put text back, switch to editing.
  Future<void> _onGuneEkle() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    try {
      final entry =
          await ref.read(entryRepositoryProvider).getTodayEntry(user.id);

      if (entry != null) {
        _textController.text = entry.text;
        _textController.selection = TextSelection.collapsed(
          offset: _textController.text.length,
        );
        debugPrint(
          '[HomeScreen] Güne ekle: loaded ${entry.text.length} chars',
        );
      }

      setState(() => _dayState = DayState.editing);
      debugPrint('[HomeScreen] State → editing');
    } catch (e) {
      debugPrint('[HomeScreen] Error in Güne ekle: $e');
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
