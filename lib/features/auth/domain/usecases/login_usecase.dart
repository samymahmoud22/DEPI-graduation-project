import 'package:firebase_auth/firebase_auth.dart';
import 'package:visionmate/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserCredential> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
