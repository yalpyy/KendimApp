import 'package:kendin/domain/entities/weekly_reflection_entity.dart';

/// Contract for weekly reflection operations.
abstract class ReflectionRepository {
  /// Triggers AI reflection generation via edge function.
  Future<void> generateReflection(
    String userId,
    DateTime weekStart, {
    bool isPremium = false,
  });

  /// Returns the reflection for a specific week, if available.
  Future<WeeklyReflectionEntity?> getReflection(
    String userId,
    DateTime weekStart,
  );

  /// Returns all archived reflections.
  Future<List<WeeklyReflectionEntity>> getArchivedReflections(String userId);

  /// Archives a reflection (premium only).
  Future<void> archiveReflection(String reflectionId);
}
