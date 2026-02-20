import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/utils/date_utils.dart';
import 'package:kendin/data/datasources/auth_datasource.dart';
import 'package:kendin/data/datasources/entry_datasource.dart';
import 'package:kendin/data/datasources/reflection_datasource.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/data/datasources/demo/demo_premium_service.dart';
import 'package:kendin/data/repositories/auth_repository_impl.dart';
import 'package:kendin/data/repositories/entry_repository_impl.dart';
import 'package:kendin/data/repositories/reflection_repository_impl.dart';
import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';
import 'package:kendin/domain/repositories/entry_repository.dart';
import 'package:kendin/domain/repositories/reflection_repository.dart';
import 'package:kendin/domain/usecases/auth_service.dart';
import 'package:kendin/domain/usecases/entry_service.dart';
import 'package:kendin/domain/usecases/reflection_service_base.dart';
import 'package:kendin/domain/usecases/strike_manager.dart';

// ─── Datasources (real Supabase) ─────────────────

final authDatasourceProvider = Provider((_) => AuthDatasource());
final entryDatasourceProvider = Provider((_) => EntryDatasource());
final reflectionDatasourceProvider = Provider((_) => ReflectionDatasource());

// ─── Repositories (real Supabase) ────────────────

final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(authDatasourceProvider)),
);

final entryRepositoryProvider = Provider<EntryRepository>(
  (ref) => EntryRepositoryImpl(ref.read(entryDatasourceProvider)),
);

final reflectionRepositoryProvider = Provider<ReflectionRepository>(
  (ref) => ReflectionRepositoryImpl(ref.read(reflectionDatasourceProvider)),
);

// ─── Services ────────────────────────────────────

final authServiceProvider = Provider(
  (ref) => AuthService(ref.read(authRepositoryProvider)),
);

final entryServiceProvider = Provider(
  (ref) => EntryService(ref.read(entryRepositoryProvider)),
);

/// No-op on web — flutter_local_notifications is native-only.
final notificationServiceProvider = Provider((_) => _NoOpNotificationService());

final strikeManagerProvider = Provider(
  (ref) => StrikeManager(
    ref.read(entryRepositoryProvider),
    updateMissTokens: (userId, newTokenCount) async {
      await SupabaseClientSetup.client
          .from('users')
          .update({
            'premium_miss_tokens': newTokenCount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    },
  ),
);

final reflectionServiceProvider = Provider<ReflectionServiceBase>(
  (ref) => _WebReflectionService(
    ref.read(reflectionRepositoryProvider),
    ref.read(strikeManagerProvider),
  ),
);

final premiumServiceProvider = Provider((_) => DemoPremiumService());

// ─── State ───────────────────────────────────────

/// Current authenticated user.
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserEntity?>>(
  (ref) => CurrentUserNotifier(ref.read(authServiceProvider)),
);

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  CurrentUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final AuthService _authService;

  Future<void> _initialize() async {
    try {
      final user = await _authService.initialize();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setUser(UserEntity user) {
    state = AsyncValue.data(user);
  }
}

/// Strike state for the current week.
final strikeStateProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(strikeManagerProvider).getStrikeState(user.id);
});

/// Today's entry.
final todayEntryProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(entryRepositoryProvider).getTodayEntry(user.id);
});

/// Current week's reflection.
final currentReflectionProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(reflectionServiceProvider).getCurrentReflection(user.id);
});

// ─── Web-safe Reflection Service ─────────────────
// Uses real Supabase repositories but skips local notifications.

class _WebReflectionService implements ReflectionServiceBase {
  _WebReflectionService(this._reflectionRepository, this._strikeManager);

  final ReflectionRepository _reflectionRepository;
  final StrikeManager _strikeManager;

  @override
  Future<bool> triggerReflection(UserEntity user) async {
    final canAccess = await _strikeManager.canAccessReflection(user);
    if (!canAccess) return false;

    final weekStart = KendinDateUtils.weekStart(DateTime.now());

    final existing = await _reflectionRepository.getReflection(
      user.id,
      weekStart,
    );
    if (existing != null) return true;

    await _reflectionRepository.generateReflection(
      user.id,
      weekStart,
      isPremium: user.isPremium,
    );

    // No notification scheduling on web.
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

/// Stub notification service for web builds.
class _NoOpNotificationService {
  Future<void> initialize() async {}
  Future<bool> requestPermission() async => true;
  Future<void> scheduleReflectionReady() async {}
  Future<void> cancelReflectionNotification() async {}
}
