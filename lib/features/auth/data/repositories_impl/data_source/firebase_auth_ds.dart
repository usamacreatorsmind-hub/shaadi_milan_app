import 'dart:ffi';

import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthDs {
  User? get currentUser;

  Stream<User?> authStateChanges();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signInAgentWithEmail(String email, String password);
  Future<void> signInUserWithEmail(String email, String password);

  Future<void> signOut();

  Future<void> signUpUserWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String gender,
    required String agentId,
    required String phone,
    required List<WishListItem> wishlists,
  });

  Future<bool> checkUserIfExists({required String uid});
  Future<bool> checkAgentIfExists({required String uid});
}

//////////////////////////////////////////////////////////
//// Implementation
//////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/// Firebase Auth Data Source Implementation
/////////////////////////////////////////////////////////////

class FirebaseAuthDS implements FirebaseAuthDs {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuthDS({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> signUpUserWithEmail({
    required String fullName,

    required String email,
    required String password,
    required String agentId,
    required String gender,

    required String phone,
    required List<WishListItem> wishlists,
  }) async {
    // Implement sign-up logic with Firebase Auth and Firestore

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // After successful authentication, store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'fullName': fullName,
        'gender': gender,

        'email': email,
        'phone': phone,
        'agentId': agentId,
        'role': 'user',
        'isProfileCreated': false,
        'createdAt': FieldValue.serverTimestamp(),
        'wishlists': wishlists,
      });
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      throw Exception(e.message);
    } catch (e) {
      // Handle other exceptions
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<bool> checkUserIfExists({required String uid}) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return userDoc.exists;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email');
    }
  }

  @override
  Future<void> signInAgentWithEmail(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("credential: $userCredential");

      final uid = userCredential.user!.uid;

      // Verify the user is an agent
      final agentDoc = await _firestore.collection('agents').doc(uid).get();

      if (!agentDoc.exists) {
        // Check if it is a user account to give a better error message
        final userDoc = await _firestore.collection('users').doc(uid).get();

        await _auth.signOut();

        if (userDoc.exists) {
          throw Exception('This is a User account. Please use User Login.');
        }
        throw Exception('This account is not registered as an agent.');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in as agent');
    } catch (e) {
      // Ensure we don't leave a half-logged-in state if something else fails
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      throw Exception('Failed to sign in as agent: $e');
    }
  }

  @override
  Future<UserCredential> signInUserWithEmail(
    String email,
    String password,
  ) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Check if user document exists, if not create it
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Check if they're an agent instead
        final agentDoc = await _firestore.collection('agents').doc(uid).get();

        if (agentDoc.exists) {
          // This is an agent trying to login as user
          await _auth.signOut();
          throw Exception('This is an agent account. Please use agent login.');
        }

        // Create user document if it doesn't exist
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': userCredential.user!.email ?? '',
          'fullName': userCredential.user!.displayName ?? '',
          'phone': '',
          'agentId': '',
          'role': 'user',
          'userType': '',
          'isProfileCreated': false,
          'metrimonyId': '',
          'profileId': '',
          'wishlists': [],
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } else {
        // Update lastSeen
        await _firestore.collection('users').doc(uid).update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in');
    } catch (e) {
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<bool> checkAgentIfExists({required String uid}) async {
    final agentDoc = await _firestore.collection('agents').doc(uid).get();
    return agentDoc.exists;
  }

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> logout() async {
    await _auth.signOut();
  }
}
