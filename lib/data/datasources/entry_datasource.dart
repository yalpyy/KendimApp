import 'package:kendin/core/errors/app_exception.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/data/models/entry_model.dart';

/// Handles entry CRUD operations against Supabase.
class EntryDatasource {
  final _client = SupabaseClientSetup.client;

  /// Creates a new daily entry.
  Future<EntryModel> createEntry(String userId, String text) async {
    try {
      final data = await _client
          .from('entries')
          .insert({'user_id': userId, 'text': text})
          .select()
          .single();
      return EntryModel.fromJson(data);
    } catch (e) {
      throw EntryException('Failed to create entry: $e');
    }
  }

  /// Returns today's entry for the user, or null.
  Future<EntryModel?> getTodayEntry(String userId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      final data = await _client
          .from('entries')
          .select()
          .eq('user_id', userId)
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', tomorrowStart.toIso8601String())
          .maybeSingle();

      if (data == null) return null;
      return EntryModel.fromJson(data);
    } catch (e) {
      throw EntryException('Failed to get today entry: $e');
    }
  }

  /// Returns entries for a given week (Mon–Sat).
  Future<List<EntryModel>> getWeekEntries(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final data = await _client
          .from('entries')
          .select()
          .eq('user_id', userId)
          .gte('created_at', weekStart.toIso8601String())
          .lte('created_at', weekEnd.toIso8601String())
          .order('created_at');

      return data.map((e) => EntryModel.fromJson(e)).toList();
    } catch (e) {
      throw EntryException('Failed to get week entries: $e');
    }
  }

  /// Returns entries in a date range.
  Future<List<EntryModel>> getEntriesInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final data = await _client
          .from('entries')
          .select()
          .eq('user_id', userId)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .order('created_at');

      return data.map((e) => EntryModel.fromJson(e)).toList();
    } catch (e) {
      throw EntryException('Failed to get entries: $e');
    }
  }
}
