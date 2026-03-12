import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/repositories/auth_repository.dart';

/// High-level auth operations.
///
/// Supports anonymous auth on first launch and email/password
/// account creation for data persistence and premium purchases.
class AuthService {
  AuthService(this._repository);

  final AuthRepository _repository;

  /// Initialize auth — returns existing user or null if not logged in.
  Future<UserEntity?> initialize() async {
    return _repository.getCurrentUser();
  }

  Future<UserEntity?> getCurrentUser() => _repository.getCurrentUser();

  /// Creates a new email/password account.
  Future<UserEntity> signUp(
    String email,
    String password,
    String displayName,
  ) =>
      _repository.signUp(email, password, displayName);

  /// Signs in with existing email/password.
  Future<UserEntity> signIn(String email, String password) =>
      _repository.signIn(email, password);

  /// Resends the email verification link.
  Future<void> resendVerificationEmail() =>
      _repository.resendVerificationEmail();

  /// Checks if email is verified.
  Future<bool> isEmailVerified() => _repository.isEmailVerified();

  /// Sends a password reset email via Supabase Auth.
  Future<void> resetPassword(String email) =>
      _repository.resetPassword(email);

  /// Migrates anonymous user data to the new email account.
  Future<void> migrateAnonymousData(String oldUserId, String newUserId) =>
      _repository.migrateAnonymousData(oldUserId, newUserId);

  /// Deletes the user's account, all data, and signs out.
  Future<void> deleteAccount(String userId) =>
      _repository.deleteAccount(userId);

  Future<void> signOut() => _repository.signOut();

  Stream<UserEntity?> get authStateChanges => _repository.authStateChanges;

  /// Returns true if the user has a real email account (not anonymous).
  bool hasAccount(UserEntity user) => !user.isAnonymous;
}
