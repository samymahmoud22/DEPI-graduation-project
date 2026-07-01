import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<void> saveUser(UserEntity user);
  Future<UserEntity?> getUser(String uid);
}
