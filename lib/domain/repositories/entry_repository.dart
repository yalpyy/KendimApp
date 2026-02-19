import 'package:kendin/domain/entities/entry_entity.dart';

/// Contract for daily entry operations.
abstract class EntryRepository {
  /// Creates a new entry for today.
  Future<EntryEntity> createEntry(String userId, String text);

  /// Returns today's entry if it exists.
  Future<EntryEntity?> getTodayEntry(String userId);

  /// Returns all entries for a given week (Mon–Sat).
  Future<List<EntryEntity>> getWeekEntries(String userId, DateTime weekStart);

  /// Returns entries for a date range.
  Future<List<EntryEntity>> getEntriesInRange(
    String userId,
    DateTime start,
    DateTime end,
  );
}
