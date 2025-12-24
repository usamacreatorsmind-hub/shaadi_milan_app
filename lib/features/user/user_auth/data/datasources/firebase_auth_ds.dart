import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// export provider

import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthDSProvider = Provider<FirebaseAuthDS>((ref) {
  return FirebaseAuthDS(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class FirebaseAuthDS {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDS({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UserCredential> signUpWithEmail(
    String email,
    String fullName,
    String password,
    String agentId,
    String phone,
  ) async {
    try {
      // 1️⃣ Validate Agent ID (if provided)
      if (agentId.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('agents')
            .where('agentId', isEqualTo: agentId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'invalid-agent-id',
            message: 'The provided Agent ID does not exist.',
          );
        }
      }

      // 2️⃣ Create Firebase Auth User
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 3️⃣ Update display name
      await userCredential.user!.updateDisplayName(fullName);

      // 4️⃣ Save user data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'role': 'user',
        'phone': phone,
        'profileId': '${phone}', // Initialize with an empty string
        'isVerified': false,
        if (agentId.isNotEmpty) 'agentId': agentId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      // Delete user from Firebase Authentication
      await user.delete();
    }
  }

  Future<bool> checkUserIfExists() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('temp_users').doc(user.uid).get();
      return doc.exists;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('temp_users').doc(uid).get();
    return doc.data();
  }

  //  register user status to fireastore define in userstatus datassource

  Future<void> signOut() => _auth.signOut();
}
