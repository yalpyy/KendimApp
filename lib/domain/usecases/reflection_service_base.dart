import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';

/// Abstract interface for reflection service.
///
/// Both [ReflectionService] (production) and the demo reflection
/// service implement this, allowing the provider to be typed
/// consistently across build targets.
abstract class ReflectionServiceBase {
  Future<bool> triggerReflection(UserEntity user);
  Future<WeeklyReflectionEntity?> getCurrentReflection(String userId);
  Future<void> archiveReflection(String reflectionId);
  Future<List<WeeklyReflectionEntity>> getArchivedReflections(String userId);
  bool isSundayMode();
  Future<bool> isReflectionReady(String userId);
}
