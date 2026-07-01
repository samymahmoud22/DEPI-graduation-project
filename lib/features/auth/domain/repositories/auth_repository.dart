import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserCredential> signup({required String email, required String password});
  Future<UserCredential> login({required String email, required String password});
  Future<void> logout();
  Future<void> resetPassword(String email);
}
