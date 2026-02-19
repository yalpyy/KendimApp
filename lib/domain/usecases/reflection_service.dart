import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';
import 'package:kendin/domain/repositories/reflection_repository.dart';
import 'package:kendin/domain/usecases/notification_service.dart';
import 'package:kendin/domain/usecases/reflection_service_base.dart';
import 'package:kendin/domain/usecases/strike_manager.dart';

/// Orchestrates the Sunday reflection flow.
///
/// Flow:
/// 1. User taps "Bu haftayı gör" on Sunday.
/// 2. Check strike eligibility.
/// 3. Trigger edge function to generate reflection.
///    - Free users get 5 sentences.
///    - Premium users get 8-12 sentences.
/// 4. Schedule local notification for 10 minutes later.
/// 5. Reflection becomes visible after the delay.
class ReflectionService implements ReflectionServiceBase {
  ReflectionService(
    this._reflectionRepository,
    this._strikeManager,
    this._notificationService,
  );

  final ReflectionRepository _reflectionRepository;
  final StrikeManager _strikeManager;
  final NotificationService _notificationService;

  @override
  Future<bool> triggerReflection(UserEntity user) async {
    final canAccess = await _strikeManager.canAccessReflection(user);
    if (!canAccess) return false;

    final weekStart = KendinDateUtils.weekStart(DateTime.now());

    // Check if reflection already exists.
    final existing = await _reflectionRepository.getReflection(
      user.id,
      weekStart,
    );
    if (existing != null) return true;

    // Trigger generation with premium flag for sentence count.
    await _reflectionRepository.generateReflection(
      user.id,
      weekStart,
      isPremium: user.isPremium,
    );

    // Schedule notification for 10 minutes from now.
    await _notificationService.scheduleReflectionReady();

    return true;
  }

  @override
  Future<WeeklyReflectionEntity?> getCurrentReflection(String userId) {
    final weekStart = KendinDateUtils.weekStart(DateTime.now());
    return _reflectionRepository.getReflection(userId, weekStart);
  }

  @override
  Future<void> archiveReflection(String reflectionId) {
    return _reflectionRepository.archiveReflection(reflectionId);
  }

  @override
  Future<List<WeeklyReflectionEntity>> getArchivedReflections(String userId) {
    return _reflectionRepository.getArchivedReflections(userId);
  }

  @override
  bool isSundayMode() => KendinDateUtils.isSunday(DateTime.now());

  @override
  Future<bool> isReflectionReady(String userId) async {
    final reflection = await getCurrentReflection(userId);
    return reflection != null;
  }
}
