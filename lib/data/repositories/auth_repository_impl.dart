import 'package:kendin/data/datasources/auth_datasource.dart';
import 'package:kendin/domain/entities/user_entity.dart';
import 'package:kendin/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<UserEntity?> getCurrentUser() => _datasource.getCurrentUser();

  @override
  Future<UserEntity> signInAnonymously() => _datasource.signInAnonymously();

  @override
  Future<UserEntity> signUp(String email, String password, String displayName) =>
      _datasource.signUp(email, password, displayName);

  @override
  Future<UserEntity> signIn(String email, String password) =>
      _datasource.signIn(email, password);

  @override
  Future<void> resendVerificationEmail() =>
      _datasource.resendVerificationEmail();

  @override
  Future<bool> isEmailVerified() => _datasource.isEmailVerified();

  @override
  Future<void> migrateAnonymousData(String oldUserId, String newUserId) =>
      _datasource.migrateAnonymousData(oldUserId, newUserId);

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Stream<UserEntity?> get authStateChanges => _datasource.authStateChanges;
}
