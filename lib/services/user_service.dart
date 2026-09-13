import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromMap(
      document.data()!,
    );
  }
  Future<void> updateUserProfile(
      String uid,
      Map<String, dynamic> data,
      ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update(data);
  }
  Stream<List<UserModel>> getUsers(String currentUid) {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
    });
  }
  Future<void> updateOnlineStatus(
      String uid,
      bool isOnline,
      ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'isOnline': isOnline,
    });
  }
}