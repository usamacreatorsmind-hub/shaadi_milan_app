import '../../../domain/repositories/metrimony_repository.dart';
import '../../../domain/states/user_status_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStatusFirestoreDS {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'user_status';

  Future<void> createUserStatus(String uid) async {
    final statusData = UserStatus.empty(id: uid).toMap();

    await _firestore.collection(_collection).doc(uid).set(statusData);
  }

  Future<void> updateUserStatus(String uid, UserStatus userStatus) async {
    await _firestore.collection(_collection).doc(uid).update({
      'isProfileCreated': userStatus.isProfileCreated,
    });
  }

  Future<void> markProfileCreated(String uid) async {
    await _firestore.collection(_collection).doc(uid).update({
      'isProfileCreated': true,
    });
  }

  Future<void> deleteUserStatus(String uid) async {
    await _firestore.collection(_collection).doc(uid).delete();
  }

  Future<UserStatus> getUserStatus(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (!doc.exists) {
      throw Exception('User status not found');
    }
    return UserStatus.fromMap(doc.data()!);
  }

  Stream<UserStatus> watchUserStatus(String uid) {
    return _firestore.collection(_collection).doc(uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return UserStatus.empty(id: uid);
      }
      return UserStatus.fromMap(snapshot.data()!);
    });
  }
}

// extract provider
final userStatusFirestoreDSProvider = Provider<UserStatusFirestoreDS>((ref) {
  return UserStatusFirestoreDS();
});
