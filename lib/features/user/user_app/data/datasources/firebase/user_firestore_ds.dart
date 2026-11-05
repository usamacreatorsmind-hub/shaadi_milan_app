import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFirestoreDSProvider = Provider<UserFirestoreDS>((ref) {
  return UserFirestoreDS(FirebaseFirestore.instance);
});

class UserFirestoreDS {
  final FirebaseFirestore _firestore;

  UserFirestoreDS(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection("users");

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final querySnapshot = await _users.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> watchOppositeGenderUsers(
    String currentUid,
  ) async* {
    // First get current user's gender
    final currentUserDoc = await _users.doc(currentUid).get();
    if (!currentUserDoc.exists) throw Exception('Current user not found');

    final currentUserGender =
        (currentUserDoc.data()?[AppConstants.fieldGender] as String?)
            ?.toLowerCase();
    if (currentUserGender == null || currentUserGender.isEmpty) {
      yield [];
      return;
    }

    // Determine opposite gender in lowercase to match stored auth values.
    final oppositeGender = switch (currentUserGender) {
      'male' => 'female',
      'female' => 'male',
      _ => '',
    };
    if (oppositeGender.isEmpty) {
      yield [];
      return;
    }

    // Watch all users except current; profile activity is validated via
    // matrimony_profiles in the next pipeline stage.
    yield* _users.snapshots().map(
      (snapshot) => snapshot.docs
          .where((doc) => doc.id != currentUid)
          .map((doc) => doc.data())
          .toList(),
    );
  }

  Future<Map<String, dynamic>> fetchUser(String uid) async {
    if (uid.isEmpty) return <String, dynamic>{};
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    return doc.data()!;
  }

  Stream<Map<String, dynamic>> watchUser(String uid) {
    if (uid.isEmpty) return Stream.value(<String, dynamic>{});
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) throw Exception('User not found');
      return doc.data()!;
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    await _users.doc(uid).update(updates);
  }

  Future<void> updateField(String uid, String fieldPath, dynamic value) async {
    await _users.doc(uid).update({fieldPath: value});
  }

  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  Future<void> updateProfileId(String uid, String profileId) async {
    await _users.doc(uid).update({'profileId': profileId});
  }

  Future<void> updateAgentId(String uid, String agentId) async {
    await _users.doc(uid).update({'agentId': agentId});
  }

  Future<void> updatePhone(String uid, String phone) async {
    await _users.doc(uid).update({'phone': phone});
  }

  Future<void> updateFullName(String uid, String fullName) async {
    await _users.doc(uid).update({'fullName': fullName});
  }

  Future<void> updateEmail(String uid, String email) async {
    await _users.doc(uid).update({'email': email});
  }

  Future<void> updatePassword(String uid, String password) async {
    await _users.doc(uid).update({'password': password});
  }

  Future<void> updateProfilePhoto(String uid, String profilePhotoUrl) async {
    await _users.doc(uid).update({'profileImageUrl': profilePhotoUrl});
  }

  Future<void> updateUserStatus(
    String uid,
    Map<String, dynamic> userStatus,
  ) async {
    await _users.doc(uid).update({'userStatus': userStatus});
  }

  Future<void> updateRole(String uid, String role) async {
    await _users.doc(uid).update({'role': role});
  }
}
