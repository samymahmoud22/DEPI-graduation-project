import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../entities/user_entity.dart';

class SignupUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SignupUseCase(this._authRepository, this._userRepository);

  Future<UserCredential> call({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authRepository.signup(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      try {
        await _userRepository.saveUser(
          UserEntity(
            uid: user.uid,
            name: name,
            email: email,
            createdAt: DateTime.now(),
          ),
        );


        await user.sendEmailVerification();
      } catch (e) {

        await user.delete();
        rethrow;
      }
    }
    return credential;
  }
}
