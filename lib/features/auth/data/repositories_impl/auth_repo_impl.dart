import 'package:arvika_marriage_bureau/features/auth/data/repositories_impl/data_source/firebase_auth_ds.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDS ds;
  final FirebaseFirestore firestore;
  AuthRepositoryImpl(this.ds, this.firestore);

  @override
  User? get currentUser => ds.currentUser;

  @override
  Stream<Either<AgentEntity, UserEntity>?>
  authStateChanges() => ds.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    // 1. Check if the user is in the 'users' collection
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      return Right(UserEntity.fromMap(data));
    }

    // 2. If not a user, check if they are in the 'agents' collection
    final agentDoc = await firestore.collection('agents').doc(user.uid).get();
    if (agentDoc.exists) {
      final data = agentDoc.data()!;
      return Left(AgentEntity.fromMap(data));
    }

    // 3. User is authenticated but has no record in Firestore yet (e.g., during sign-up).
    // Default to a non-profile-created user state.
    return Right(
      UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        fullName: '',
        phone: '',
        profileImageUrl: '',
        agentId: '',
        userType: '',
        isProfileCreated: false,
        wishlists: const [],
        metrimonyId: '',
        profileId: '',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        role: 'user',
      ),
    );
  });

  @override
  Future<void> signOut() async {
    await ds.signOut();
  }

  // @override
  // Future<bool> checkUserIfExists({String? uid}) async {
  //   final targetUid = uid ?? currentUser?.uid;
  //   if (targetUid == null) return false;
  //   return await ds.checkUserIfExists(uid: targetUid);
  // }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return ds.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signInAgentWithEmail(String email, String password) {
    return ds.signInAgentWithEmail(email, password);
  }

  @override
  Future<void> signInUserWithEmail(String email, String password) {
    return ds.signInUserWithEmail(email, password);
  }

  @override
  Future<UserCredential> signInWithEmail(String email, String password) {
    return ds.signInUserWithEmail(email, password);
  }

  @override
  Future<void> signUpUserWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String agentId,
    required String phone,
    required List<dynamic> wishlists,
  }) async {
    await ds.signUpUserWithEmail(
      fullName: fullName,
      email: email,
      password: password,
      agentId: agentId,
      phone: phone,
      wishlists: const [],
    );
  }

  @override
  Future<void> logout() {
    return ds.logout();
  }

  // @override
  // Future<bool> checkAgentIfExists() async {
  //   return await ds.checkAgentIfExists(uid: currentUser?.uid ?? '');
  // }
}
