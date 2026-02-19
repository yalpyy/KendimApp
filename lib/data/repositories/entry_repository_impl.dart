import 'package:kendin/data/datasources/entry_datasource.dart';
import 'package:kendin/domain/entities/entry_entity.dart';
import 'package:kendin/domain/repositories/entry_repository.dart';

class EntryRepositoryImpl implements EntryRepository {
  EntryRepositoryImpl(this._datasource);

  final EntryDatasource _datasource;

  @override
  Future<EntryEntity> createEntry(String userId, String text) =>
      _datasource.createEntry(userId, text);

  @override
  Future<EntryEntity> updateEntry(String entryId, String text) =>
      _datasource.updateEntry(entryId, text);

  @override
  Future<EntryEntity?> getTodayEntry(String userId) =>
      _datasource.getTodayEntry(userId);

  @override
  Future<List<EntryEntity>> getWeekEntries(
    String userId,
    DateTime weekStart,
  ) =>
      _datasource.getWeekEntries(userId, weekStart);

  @override
  Future<List<EntryEntity>> getEntriesInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) =>
      _datasource.getEntriesInRange(userId, start, end);
}
