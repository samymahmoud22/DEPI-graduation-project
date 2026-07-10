import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/usecases/signup_usecase.dart';

final signupControllerProvider =
    ChangeNotifierProvider<SignupController>((ref) {
  final signupUseCase = ref.read(signupUseCaseProvider);
  return SignupController(signupUseCase: signupUseCase);
});

class SignupController extends ChangeNotifier {
  final SignupUseCase _signupUseCase;

  SignupController({
    required SignupUseCase signupUseCase,
  }) : _signupUseCase = signupUseCase;

  bool isLoading = false;
  String? errorMessage;

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    errorMessage = null;

    if (name.trim().isEmpty) {
      errorMessage = 'Please enter your name';
      notifyListeners();
      return false;
    }

    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    if (password.trim().length < 6) {
      errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    if (password.trim() != confirmPassword.trim()) {
      errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      await _signupUseCase(
        name: name.trim(),
        email: email.trim(),
        password: password.trim(),
      );

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}