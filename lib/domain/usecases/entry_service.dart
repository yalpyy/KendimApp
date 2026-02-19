import 'package:flutter/foundation.dart';

import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/repositories/entry_repository.dart';

/// Handles daily entry save-or-update logic and weekly strike counting.
class EntryService {
  EntryService(this._repository);

  final EntryRepository _repository;

  /// Saves today's entry. Inserts if first write, updates if already exists.
  ///
  /// Only ONE entry per user per calendar day.
  Future<void> saveOrUpdateTodayEntry(String userId, String text) async {
    try {
      final existing = await _repository.getTodayEntry(userId);

      if (existing != null) {
        debugPrint('[EntryService] UPDATE existing entry id=${existing.id}');
        await _repository.updateEntry(existing.id, text);
      } else {
        debugPrint('[EntryService] INSERT new entry for user=$userId');
        await _repository.createEntry(userId, text);
      }
    } catch (e) {
      debugPrint('[EntryService] Error in saveOrUpdateTodayEntry: $e');
      rethrow;
    }
  }

  /// Returns the number of distinct writing days (Mon–Sat) with entries
  /// in the current week (starting Monday).
  Future<int> getWeeklyStrikeCount(String userId) async {
    try {
      final now = DateTime.now();
      final monday = KendinDateUtils.weekStart(now);
      final entries = await _repository.getWeekEntries(userId, monday);

      final distinctDays = <int>{};
      for (final entry in entries) {
        final weekday = entry.createdAt.weekday;
        if (weekday >= DateTime.monday && weekday <= DateTime.saturday) {
          distinctDays.add(weekday);
        }
      }

      debugPrint('[EntryService] Weekly strike count: ${distinctDays.length}');
      return distinctDays.length;
    } catch (e) {
      debugPrint('[EntryService] Error in getWeeklyStrikeCount: $e');
      rethrow;
    }
  }
}
