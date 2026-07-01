import 'package:visionmate/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:visionmate/features/auth/data/models/user_profile_model.dart';
import 'package:visionmate/features/auth/domain/entities/user_entity.dart';
import 'package:visionmate/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> saveUser(UserEntity user) async {
    final model = UserProfileModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
    );
    await _remoteDataSource.saveUser(model);
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    return await _remoteDataSource.getUser(uid);
  }
}
