import 'dart:async';

import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/repositories/auth_repository.dart';

/// In-memory auth repository for demo mode.
///
/// Provides a static demo user. Auth methods are no-ops
/// that return the same user (since there's no backend).
class DemoAuthRepository implements AuthRepository {
  static const _demoUser = UserEntity(
    id: 'demo-user-001',
    isPremium: true,
    premiumMissTokens: 3,
    email: 'demo@kendin.app',
    displayName: 'Demo',
    isAnonymous: false,
    emailVerified: true,
  );

  final _controller = StreamController<UserEntity?>.broadcast();

  @override
  Future<UserEntity?> getCurrentUser() async => _demoUser;

  @override
  Future<UserEntity> signInAnonymously() async => _demoUser;

  @override
  Future<UserEntity> signUp(
    String email,
    String password,
    String displayName,
  ) async =>
      _demoUser;

  @override
  Future<UserEntity> signIn(String email, String password) async => _demoUser;

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<bool> isEmailVerified() async => true;

  @override
  Future<void> migrateAnonymousData(String oldUserId, String newUserId) async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;
}
