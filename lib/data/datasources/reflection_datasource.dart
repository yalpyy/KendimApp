import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kendin/core/errors/app_exception.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/data/models/weekly_reflection_model.dart';

/// Handles reflection operations against Supabase.
class ReflectionDatasource {
  final _client = SupabaseClientSetup.client;

  /// Invokes the edge function to generate a weekly reflection.
  Future<void> generateReflection(
    String userId,
    DateTime weekStart, {
    bool isPremium = false,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-reflection',
        body: {
          'user_id': userId,
          'week_start_date': weekStart.toIso8601String().split('T').first,
          'is_premium': isPremium,
        },
      );

      if (response.status != 200) {
        throw ReflectionException(
          'Edge function returned ${response.status}',
        );
      }
    } on FunctionException catch (e) {
      throw ReflectionException('Failed to generate reflection: $e');
    }
  }

  /// Returns the reflection for a specific week.
  Future<WeeklyReflectionModel?> getReflection(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      final dateStr = weekStart.toIso8601String().split('T').first;
      final data = await _client
          .from('weekly_reflections')
          .select()
          .eq('user_id', userId)
          .eq('week_start_date', dateStr)
          .maybeSingle();

      if (data == null) return null;
      return WeeklyReflectionModel.fromJson(data);
    } catch (e) {
      throw ReflectionException('Failed to get reflection: $e');
    }
  }

  /// Returns all archived reflections for the user.
  Future<List<WeeklyReflectionModel>> getArchivedReflections(
    String userId,
  ) async {
    try {
      final data = await _client
          .from('weekly_reflections')
          .select()
          .eq('user_id', userId)
          .eq('is_archived', true)
          .order('week_start_date', ascending: false);

      return data.map((e) => WeeklyReflectionModel.fromJson(e)).toList();
    } catch (e) {
      throw ReflectionException('Failed to get archived reflections: $e');
    }
  }

  /// Archives a reflection.
  Future<void> archiveReflection(String reflectionId) async {
    try {
      await _client
          .from('weekly_reflections')
          .update({'is_archived': true})
          .eq('id', reflectionId);
    } catch (e) {
      throw ReflectionException('Failed to archive reflection: $e');
    }
  }
}
