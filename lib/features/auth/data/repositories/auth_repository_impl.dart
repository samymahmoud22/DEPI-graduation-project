import 'package:firebase_auth/firebase_auth.dart';
import 'package:visionmate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:visionmate/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges();

  @override
  Future<UserCredential> signup({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signup(email: email, password: password);
  }

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  Future<void> resetPassword(String email) {
    return _remoteDataSource.resetPassword(email);
  }
}
