import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../user_app/domain/states/user_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDS ds;
  final FirebaseFirestore firestore;
  AuthRepositoryImpl(this.ds, this.firestore);

  @override
  User? get currentUser => ds.currentUser;

  @override
  Stream<AppUser?> authStateChanges() =>
      ds.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          return AppUser(
            isProfileCreated: data['isProfileCreated'] ?? false,

            metrimonyId: data['metrimonyId'] ?? '',

            wishlists: (data['wishlists'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList(),

            uid: user.uid,
            fullName: data['fullName'] ?? user.displayName ?? '',
            email: user.email ?? '',
            role: data['role'] ?? 'user',

            phone: data['phone'] ?? '',
            profileId: data['profileId'] ?? '',
            agentId: data['agentId'],
          );
        } else {
          // User is authenticated but no document in 'users' collection yet.
          // This can happen right after signup.
          return AppUser(
            isProfileCreated: false,

            metrimonyId: '',

            uid: user.uid,
            fullName: user.displayName ?? '',
            email: user.email ?? '',
            role: 'user',
            phone: '',
            profileId: '',
            agentId: '',
          );
        }
      });

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await ds.signInWithEmail(email, password);
  }

  @override
  Future<void> signOut() async {
    await ds.signOut();
  }

  @override
  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String agentId,
    required String phone,
    List<String> wishlists = const [],
  }) async {
    // fetch agent id using agent_id field using agent repository

    await ds.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
      agentId: agentId,
      phone: phone,
      wishlists: wishlists,
    );
  }

  @override
  Future<bool> checkUserIfExists() async {
    return await ds.checkUserIfExists();
  }

  @override
  Future<void> sendPasswordResetEmail(String trim) {
    return ds.sendPasswordResetEmail(trim);
  }
}
