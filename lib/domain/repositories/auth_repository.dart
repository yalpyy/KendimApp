import 'package:kendin/domain/entities/user_entity.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Returns the current user or null.
  Future<UserEntity?> getCurrentUser();

  /// Signs in anonymously. Called on first launch.
  Future<UserEntity> signInAnonymously();

  /// Links the anonymous account with Apple credentials.
  Future<UserEntity> linkWithApple();

  /// Links the anonymous account with Google credentials.
  Future<UserEntity> linkWithGoogle();

  /// Links the anonymous account with email/password.
  Future<UserEntity> linkWithEmail(String email, String password);

  /// Signs out the current user.
  Future<void> signOut();

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;
}
