import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/states/user_status_state.dart';

class UserStatusFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ---------------- FETCH (ONE TIME) ----------------
  Future<UserStatus> fetchUserStatus(String uid) async {
    try {
      final doc = _firestore
          .collection('userStatus')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              return const UserStatus.empty(); // default empty status
            }
            return UserStatus.fromMap(snapshot.data()!);
          });
      return await doc.first;
    } catch (e) {
      throw Exception('Failed to fetch user status: $e');
    }
  }

  /// ---------------- REAL-TIME LISTENER ----------------
  Stream<UserStatus> watchUserStatus(String uid) {
    return _firestore.collection('userStatus').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return const UserStatus.empty();
      }
      return UserStatus.fromMap(snapshot.data()!);
    });
  }

  /// ---------------- UPDATE (MERGE SAFE) ----------------
  Future<void> updateUserStatus(String uid, UserStatus userStatus) async {
    try {
      await _firestore
          .collection('userStatus')
          .doc(uid)
          .set(userStatus.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }
}
