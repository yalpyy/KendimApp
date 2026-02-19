import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/entities/entry_entity.dart';
import 'package:kendin/domain/repositories/entry_repository.dart';

/// In-memory entry repository for demo mode.
///
/// Stores entries in a list that persists for the session.
/// No Supabase dependency.
class DemoEntryRepository implements EntryRepository {
  final List<EntryEntity> _entries = [];
  int _idCounter = 0;

  @override
  Future<EntryEntity> createEntry(String userId, String text) async {
    _idCounter++;
    final entry = EntryEntity(
      id: 'demo-entry-$_idCounter',
      userId: userId,
      text: text,
      createdAt: DateTime.now(),
    );
    _entries.add(entry);
    return entry;
  }

  @override
  Future<EntryEntity?> getTodayEntry(String userId) async {
    final now = DateTime.now();
    for (final entry in _entries.reversed) {
      if (entry.userId == userId && KendinDateUtils.isSameDay(entry.createdAt, now)) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<List<EntryEntity>> getWeekEntries(
    String userId,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59));
    return _entries
        .where((e) =>
            e.userId == userId &&
            !e.createdAt.isBefore(weekStart) &&
            !e.createdAt.isAfter(weekEnd))
        .toList();
  }

  @override
  Future<List<EntryEntity>> getEntriesInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    return _entries
        .where((e) =>
            e.userId == userId &&
            !e.createdAt.isBefore(start) &&
            !e.createdAt.isAfter(end))
        .toList();
  }
}
