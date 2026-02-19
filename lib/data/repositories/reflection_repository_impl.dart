import 'package:kendin/data/datasources/reflection_datasource.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';
import 'package:kendin/domain/repositories/reflection_repository.dart';

class ReflectionRepositoryImpl implements ReflectionRepository {
  ReflectionRepositoryImpl(this._datasource);

  final ReflectionDatasource _datasource;

  @override
  Future<void> generateReflection(
    String userId,
    DateTime weekStart, {
    bool isPremium = false,
  }) =>
      _datasource.generateReflection(userId, weekStart, isPremium: isPremium);

  @override
  Future<WeeklyReflectionEntity?> getReflection(
    String userId,
    DateTime weekStart,
  ) =>
      _datasource.getReflection(userId, weekStart);

  @override
  Future<List<WeeklyReflectionEntity>> getArchivedReflections(String userId) =>
      _datasource.getArchivedReflections(userId);

  @override
  Future<void> archiveReflection(String reflectionId) =>
      _datasource.archiveReflection(reflectionId);
}
