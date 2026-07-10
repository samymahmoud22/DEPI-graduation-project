import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  User? call() {
    return _repository.currentUser;
  }
}
