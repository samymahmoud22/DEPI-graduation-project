import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  Future<void> saveUser(UserProfileModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserProfileModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserProfileModel.fromMap(doc.data()!);
  }
}