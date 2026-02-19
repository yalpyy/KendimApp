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
  Future<UserEntity> linkWithApple() => _datasource.linkWithApple();

  @override
  Future<UserEntity> linkWithGoogle() => _datasource.linkWithGoogle();

  @override
  Future<UserEntity> linkWithEmail(String email, String password) =>
      _datasource.linkWithEmail(email, password);

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Stream<UserEntity?> get authStateChanges => _datasource.authStateChanges;
}
