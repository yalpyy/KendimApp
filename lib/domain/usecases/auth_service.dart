import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/repositories/auth_repository.dart';

/// High-level auth operations.
///
/// Ensures anonymous auth on first launch, and account linking
/// for data persistence and premium purchases.
class AuthService {
  AuthService(this._repository);

  final AuthRepository _repository;

  /// Initialize auth — sign in anonymously if no session exists.
  Future<UserEntity> initialize() async {
    final existing = await _repository.getCurrentUser();
    if (existing != null) return existing;
    return _repository.signInAnonymously();
  }

  Future<UserEntity?> getCurrentUser() => _repository.getCurrentUser();

  Future<UserEntity> linkWithApple() => _repository.linkWithApple();

  Future<UserEntity> linkWithGoogle() => _repository.linkWithGoogle();

  Future<UserEntity> linkWithEmail(String email, String password) =>
      _repository.linkWithEmail(email, password);

  Future<void> signOut() => _repository.signOut();

  Stream<UserEntity?> get authStateChanges => _repository.authStateChanges;

  /// Returns true if the user has linked a real identity.
  bool isAccountLinked(UserEntity user) => !user.isAnonymous;
}
