import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/data/datasources/demo/demo_auth_repository.dart';
import 'package:kendin/data/datasources/demo/demo_entry_repository.dart';
import 'package:kendin/data/datasources/demo/demo_notification_service.dart';
import 'package:kendin/data/datasources/demo/demo_premium_service.dart';
import 'package:kendin/data/datasources/demo/demo_reflection_repository.dart';
import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';
import 'package:kendin/domain/repositories/entry_repository.dart';
import 'package:kendin/domain/repositories/reflection_repository.dart';
import 'package:kendin/domain/usecases/auth_service.dart';
import 'package:kendin/domain/usecases/reflection_service_base.dart';
import 'package:kendin/domain/usecases/strike_manager.dart';

// ─── Demo Datasources ─────────────────────────────
// These are web-safe: no Supabase, no dart:io, no native plugins.

final _demoAuthRepository = DemoAuthRepository();
final _demoEntryRepository = DemoEntryRepository();

final authDatasourceProvider = Provider((_) => _demoAuthRepository);
final entryDatasourceProvider = Provider((_) => _demoEntryRepository);
final reflectionDatasourceProvider = Provider(
  (_) => DemoReflectionRepository(_demoEntryRepository),
);

// ─── Repositories ─────────────────────────────────

final authRepositoryProvider = Provider((_) => _demoAuthRepository);

final entryRepositoryProvider = Provider<EntryRepository>(
  (_) => _demoEntryRepository,
);

final reflectionRepositoryProvider = Provider<ReflectionRepository>(
  (_) => DemoReflectionRepository(_demoEntryRepository),
);

// ─── Services ─────────────────────────────────────

final authServiceProvider = Provider(
  (ref) => AuthService(_demoAuthRepository),
);

final notificationServiceProvider = Provider((_) => DemoNotificationService());

final strikeManagerProvider = Provider(
  (ref) => StrikeManager(ref.read(entryRepositoryProvider)),
);

final reflectionServiceProvider = Provider<ReflectionServiceBase>(
  (ref) => _DemoReflectionService(
    ref.read(reflectionRepositoryProvider),
  ),
);

final premiumServiceProvider = Provider((_) => DemoPremiumService());

// ─── State ────────────────────────────────────────

/// Current authenticated user (demo: resolved immediately).
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

// ─── Demo Reflection Service ──────────────────────
// Lightweight: generates mock reflection instantly, no notifications.

class _DemoReflectionService implements ReflectionServiceBase {
  _DemoReflectionService(this._reflectionRepository);

  final ReflectionRepository _reflectionRepository;

  @override
  Future<bool> triggerReflection(UserEntity user) async {
    // In demo mode, always allow reflection regardless of strike.
    final weekStart = _weekStart(DateTime.now());

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
    return true;
  }

  @override
  Future<WeeklyReflectionEntity?> getCurrentReflection(String userId) {
    final weekStart = _weekStart(DateTime.now());
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
  bool isSundayMode() => DateTime.now().weekday == DateTime.sunday;

  @override
  Future<bool> isReflectionReady(String userId) async {
    final reflection = await getCurrentReflection(userId);
    return reflection != null;
  }

  DateTime _weekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }
}
