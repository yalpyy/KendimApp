import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/data/datasources/auth_datasource.dart';
import 'package:kendin/data/datasources/entry_datasource.dart';
import 'package:kendin/data/datasources/reflection_datasource.dart';
import 'package:kendin/data/repositories/auth_repository_impl.dart';
import 'package:kendin/data/repositories/entry_repository_impl.dart';
import 'package:kendin/data/repositories/reflection_repository_impl.dart';
import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/usecases/auth_service.dart';
import 'package:kendin/domain/usecases/notification_service.dart';
import 'package:kendin/domain/usecases/premium_service.dart';
import 'package:kendin/domain/usecases/reflection_service.dart';
import 'package:kendin/domain/usecases/strike_manager.dart';

// ─── Datasources ──────────────────────────────────

final authDatasourceProvider = Provider((_) => AuthDatasource());
final entryDatasourceProvider = Provider((_) => EntryDatasource());
final reflectionDatasourceProvider = Provider((_) => ReflectionDatasource());

// ─── Repositories ─────────────────────────────────

final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(authDatasourceProvider)),
);

final entryRepositoryProvider = Provider(
  (ref) => EntryRepositoryImpl(ref.read(entryDatasourceProvider)),
);

final reflectionRepositoryProvider = Provider(
  (ref) => ReflectionRepositoryImpl(ref.read(reflectionDatasourceProvider)),
);

// ─── Services ─────────────────────────────────────

final authServiceProvider = Provider(
  (ref) => AuthService(ref.read(authRepositoryProvider)),
);

final notificationServiceProvider = Provider((_) => NotificationService());

final strikeManagerProvider = Provider(
  (ref) => StrikeManager(ref.read(entryRepositoryProvider)),
);

final reflectionServiceProvider = Provider(
  (ref) => ReflectionService(
    ref.read(reflectionRepositoryProvider),
    ref.read(strikeManagerProvider),
    ref.read(notificationServiceProvider),
  ),
);

final premiumServiceProvider = Provider((_) => PremiumService());

// ─── State ────────────────────────────────────────

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
  return ref.read(entryDatasourceProvider).getTodayEntry(user.id);
});

/// Current week's reflection.
final currentReflectionProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  return ref.read(reflectionServiceProvider).getCurrentReflection(user.id);
});
