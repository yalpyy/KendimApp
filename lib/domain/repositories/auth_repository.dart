import 'package:kendin/domain/entities/user_entity.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Returns the current user or null.
  Future<UserEntity?> getCurrentUser();

  /// Signs in anonymously. Called on first launch.
  Future<UserEntity> signInAnonymously();

  /// Creates a new email/password account.
  Future<UserEntity> signUp(String email, String password, String displayName);

  /// Signs in with existing email/password.
  Future<UserEntity> signIn(String email, String password);

  /// Resends the email verification link.
  Future<void> resendVerificationEmail();

  /// Returns true if the user's email is verified.
  Future<bool> isEmailVerified();

  /// Migrates data from anonymous account to the new email account.
  /// Calls the migrate-user-data edge function.
  Future<void> migrateAnonymousData(String oldUserId, String newUserId);

  /// Deletes the user's account and all associated data.
  Future<void> deleteAccount(String userId);

  /// Signs out the current user.
  Future<void> signOut();

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;
}
