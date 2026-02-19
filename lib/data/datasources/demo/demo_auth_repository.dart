import 'dart:async';

import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/repositories/auth_repository.dart';

/// In-memory auth repository for demo mode.
///
/// Provides a static demo user. Account linking methods are no-ops
/// that return the same user (since there's no backend).
class DemoAuthRepository implements AuthRepository {
  static const _demoUser = UserEntity(
    id: 'demo-user-001',
    isPremium: true,
    premiumMissTokens: 3,
    email: null,
    isAnonymous: false,
  );

  final _controller = StreamController<UserEntity?>.broadcast();

  @override
  Future<UserEntity?> getCurrentUser() async => _demoUser;

  @override
  Future<UserEntity> signInAnonymously() async => _demoUser;

  @override
  Future<UserEntity> linkWithApple() async => _demoUser;

  @override
  Future<UserEntity> linkWithGoogle() async => _demoUser;

  @override
  Future<UserEntity> linkWithEmail(String email, String password) async =>
      _demoUser;

  @override
  Future<void> signOut() async {}

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;
}
