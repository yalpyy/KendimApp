import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/usecases/strike_manager.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/menu/menu_screen.dart';
import 'package:kendin/presentation/screens/reflection/reflection_screen.dart';
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
///   - If exists → completed state
///   - If not   → editing state (question + text field + "Yazdım")
///
/// On Sunday: shows "Bu haftayı gör" instead.
///
/// Features:
/// - 23:30 subtle banner if entry not written
/// - Strike dots fade out after 1 second on app open
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  /// null = not yet determined (waiting for todayEntry to load).
  DayState? _dayState;
  bool _initialized = false;

  // Strike dot fade animation
  late final AnimationController _strikeFadeController;
  late final Animation<double> _strikeFadeAnimation;
  bool _strikeShownOnce = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);

    // Fade controller: dots visible for 2s, then fade out over 0.5s
    _strikeFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _strikeFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _strikeFadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _strikeFadeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  /// Start strike fade-out after a brief display.
  void _scheduleStrikeFadeIfNeeded() {
    if (_strikeShownOnce) return;
    _strikeShownOnce = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _strikeFadeController.forward();
    });
  }

  /// Whether to show the "Gün kapanıyor" banner.
  bool get _showDayClosingNotice {
    final now = DateTime.now();
    return now.hour >= 23 && now.minute >= 30 && _dayState != DayState.completed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

    // Schedule strike fade when data arrives
    strikeAsync.whenData((_) => _scheduleStrikeFadeIfNeeded());

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // 23:30 notice banner
              if (_showDayClosingNotice)
                _DayClosingBanner(text: l10n.dayClosingNotice),

              // Top bar — fixed
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_horiz),
                          onPressed: () => _openMenu(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xxl),

                      // Date
                      const DateHeader(),
                      const SizedBox(height: AppSpacing.sm),

                      // ── Sunday flow ──
                      if (isSunday) ...[
                        _buildStrikeRow(strikeAsync, fade: false),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          l10n.seeThisWeek,
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
                        _buildStrikeRow(strikeAsync, fade: true),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          l10n.mainQuestion,
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildEditingContent(context),
                      ],

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Strike row (reused in editing + sunday) ───────

  Widget _buildStrikeRow(AsyncValue<StrikeState?> strikeAsync, {bool fade = false}) {
    return strikeAsync.when(
      data: (strike) {
        if (strike == null) return const SizedBox.shrink();
        final indicator = StrikeIndicator(
          completedDays: strike.completedDays,
          daysWithEntries: strike.daysWithEntries,
        );
        if (!fade) return indicator;
        return FadeTransition(
          opacity: _strikeFadeAnimation,
          child: indicator,
        );
      },
      loading: () => const SizedBox(height: AppSpacing.strikeDotSize),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── Editing State ─────────────────────────────────

  Widget _buildEditingContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: KendinTextField(
            controller: _textController,
            enabled: true,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        KendinButton(
          label: l10n.writeButton,
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
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final isSaturday = now.weekday == DateTime.saturday;
    final strike = strikeAsync.valueOrNull;
    final isSaturdayComplete =
        isSaturday && strike != null && strike.completedDays >= 6;

    return Column(
      children: [
        if (isSaturdayComplete) ...[
          Text(
            l10n.saturdayCompletedTitle,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.saturdayCompletedSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ] else
          Text(
            l10n.dayCompletedMessage,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),

        const SizedBox(height: AppSpacing.lg),
        _buildStrikeRow(strikeAsync, fade: false),
        const SizedBox(height: AppSpacing.lg),

        KendinButton(
          label: l10n.addToDay,
          onPressed: () => _onGuneEkle(),
        ),
      ],
    );
  }

  // ─── Sunday State ──────────────────────────────────

  Widget _buildSundayContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final strikeAsync = ref.watch(strikeStateProvider);

    return strikeAsync.when(
      data: (strike) {
        if (strike == null) return const SizedBox.shrink();

        return Column(
          children: [
            Text(
              '${strike.completedDays}/${strike.totalDays}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            KendinButton(
              label: l10n.seeThisWeek,
              isLoading: _isSubmitting,
              onPressed: () => _triggerReflection(context, strike),
            ),

            if (!strike.isWeekComplete)
              userAsync.when(
                data: (user) {
                  if (user == null || !user.isPremium) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: TextButton(
                      onPressed: () => _useMissTokens(),
                      child: Text('${user.premiumMissTokens}'),
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
        l10n.genericError,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────

  Future<void> _submitEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      debugPrint('[HomeScreen] Cannot submit — user is null (auth failed)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

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

      ref.invalidate(strikeStateProvider);
      ref.invalidate(todayEntryProvider);
    } catch (e) {
      debugPrint('[HomeScreen] Error saving entry: $e');
      setState(() => _isSubmitting = false);
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
      }

      setState(() => _dayState = DayState.editing);
    } catch (e) {
      debugPrint('[HomeScreen] Error in Güne ekle: $e');
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

  Future<void> _triggerReflection(
    BuildContext context,
    StrikeState strike,
  ) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    if (!strike.isWeekComplete && !user.isPremium) return;

    setState(() => _isSubmitting = true);

    try {
      final triggered =
          await ref.read(reflectionServiceProvider).triggerReflection(user);

      setState(() => _isSubmitting = false);

      if (triggered && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReflectionScreen()),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
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
            content: Text(AppLocalizations.of(context).genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openMenu(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }
}

/// Subtle top banner: "Gün kapanıyor."
class _DayClosingBanner extends StatelessWidget {
  const _DayClosingBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.screenHorizontal,
      ),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
