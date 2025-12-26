import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFirestoreDSProvider = Provider<UserFirestoreDS>((ref) {
  return UserFirestoreDS(FirebaseFirestore.instance);
});

class UserFirestoreDS {
  final FirebaseFirestore _firestore;

  UserFirestoreDS(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<Map<String, dynamic>> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    return doc.data()!;
  }

  Stream<Map<String, dynamic>> watchUser(String uid) {
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
    await _users.doc(uid).update({'profilePhoto': profilePhotoUrl});
  }

  // implement add to wishlist  in user collection
  Future<void> addWishlist(String uid, String profileId) async {
    await _users.doc(uid).update({
      'wishlists': FieldValue.arrayUnion([profileId]),
    });
  }

  Future<void> removeWishlist(String uid, String profileId) async {
    await _users.doc(uid).update({
      'wishlists': FieldValue.arrayRemove([profileId]),
    });
  }
}
