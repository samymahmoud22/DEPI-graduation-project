import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

enum LoginResult { success, emailNotVerified, error }

final loginControllerProvider = ChangeNotifierProvider<LoginController>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  final resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);
  return LoginController(
    loginUseCase: loginUseCase,
    resetPasswordUseCase: resetPasswordUseCase,
  );
});

class LoginController extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  LoginController({
    required LoginUseCase loginUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _loginUseCase = loginUseCase,
        _resetPasswordUseCase = resetPasswordUseCase;

  bool isLoading = false;
  String? errorMessage;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    errorMessage = null;

    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email';
      notifyListeners();
      return LoginResult.error;
    }

    if (password.trim().isEmpty) {
      errorMessage = 'Please enter your password';
      notifyListeners();
      return LoginResult.error;
    }

    try {
      isLoading = true;
      notifyListeners();

      final credential = await _loginUseCase(
        email: email,
        password: password,
      );

      // Check if email is verified
      final user = credential.user;
      if (user != null && !user.emailVerified) {
        // Sign out the unverified user
        await user.reload();
        if (!user.emailVerified) {
          return LoginResult.emailNotVerified;
        }
      }

      return LoginResult.success;
    } catch (e) {
      errorMessage = e.toString();
      return LoginResult.error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email first';
      notifyListeners();
      return;
    }

    try {
      await _resetPasswordUseCase(email);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}