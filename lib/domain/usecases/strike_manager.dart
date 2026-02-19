import 'package:kendin/core/constants/app_constants.dart';
import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/entities/entry_entity.dart';
import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/repositories/entry_repository.dart';

/// Callback to persist the updated miss token count.
/// Injected by the provider — Supabase in production, no-op in demo.
typedef UpdateMissTokens = Future<void> Function(
  String userId,
  int newTokenCount,
);

/// Strike state for the current week.
class StrikeState {
  const StrikeState({
    required this.completedDays,
    required this.totalDays,
    required this.daysWithEntries,
    required this.missingDays,
    required this.isWeekComplete,
  });

  /// Number of days with entries this week (Mon–Sat).
  final int completedDays;

  /// Total writing days in the week (6).
  final int totalDays;

  /// Which days (weekday numbers 1–6) have entries.
  final Set<int> daysWithEntries;

  /// Which days (weekday numbers 1–6) are missing entries.
  final List<int> missingDays;

  /// True if all 6 writing days are completed.
  final bool isWeekComplete;
}

/// Manages the weekly strike system.
///
/// Week cycle: Mon–Sat are writing days. Sunday is reflection day.
/// Users must complete all 6 days to unlock the weekly reflection.
/// Premium users can use miss tokens to fill gaps.
class StrikeManager {
  StrikeManager(this._entryRepository, {UpdateMissTokens? updateMissTokens})
      : _updateMissTokens = updateMissTokens;

  final EntryRepository _entryRepository;
  final UpdateMissTokens? _updateMissTokens;

  /// Computes the strike state for the current week.
  Future<StrikeState> getStrikeState(String userId) async {
    final now = DateTime.now();
    final weekStart = KendinDateUtils.weekStart(now);

    final entries = await _entryRepository.getWeekEntries(userId, weekStart);
    return _computeStrike(entries, now);
  }

  /// Returns true if the user can access the weekly reflection.
  ///
  /// Requires either:
  /// - All 6 days completed, OR
  /// - Premium user with enough miss tokens to cover missing days.
  Future<bool> canAccessReflection(UserEntity user) async {
    final strike = await getStrikeState(user.id);
    if (strike.isWeekComplete) return true;
    if (!user.isPremium) return false;
    return user.premiumMissTokens >= strike.missingDays.length;
  }

  /// Uses miss tokens to fill missing days. Returns updated token count.
  Future<int> useMissTokens(UserEntity user) async {
    final strike = await getStrikeState(user.id);
    final tokensNeeded = strike.missingDays.length;

    if (tokensNeeded == 0) return user.premiumMissTokens;
    if (user.premiumMissTokens < tokensNeeded) {
      throw Exception('Not enough miss tokens');
    }

    final newTokenCount = user.premiumMissTokens - tokensNeeded;

    if (_updateMissTokens != null) {
      await _updateMissTokens!(user.id, newTokenCount);
    }

    return newTokenCount;
  }

  /// Determines how many days have passed in the current week up to now.
  int _writingDaysSoFar(DateTime now) {
    if (KendinDateUtils.isSunday(now)) {
      return AppConstants.writingDaysPerWeek;
    }
    // weekday: 1=Mon, 6=Sat
    return now.weekday.clamp(1, 6);
  }

  StrikeState _computeStrike(List<EntryEntity> entries, DateTime now) {
    final daysWithEntries = <int>{};

    for (final entry in entries) {
      final weekday = entry.createdAt.weekday;
      if (weekday >= DateTime.monday && weekday <= DateTime.saturday) {
        daysWithEntries.add(weekday);
      }
    }

    final daysSoFar = _writingDaysSoFar(now);
    final missingDays = <int>[];
    for (var d = 1; d <= daysSoFar; d++) {
      if (!daysWithEntries.contains(d)) {
        missingDays.add(d);
      }
    }

    return StrikeState(
      completedDays: daysWithEntries.length,
      totalDays: AppConstants.writingDaysPerWeek,
      daysWithEntries: daysWithEntries,
      missingDays: missingDays,
      isWeekComplete:
          daysWithEntries.length >= AppConstants.writingDaysPerWeek,
    );
  }
}
