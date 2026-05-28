import 'dart:async';

import 'data_source/firebase_auth_ds.dart';
import '../../domain/states/agent_state.dart';
import '../../domain/states/user_state.dart';
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
  Future<dynamic> checkPhoneAlreadyRegistered(String phone) async {
    final usersQuery = await firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    if (usersQuery.docs.isNotEmpty) {
      return true;
    }

    final agentsQuery = await firestore
        .collection('agents')
        .where('phone', isEqualTo: phone)
        .get();
    if (agentsQuery.docs.isNotEmpty) {
      return true;
    }

    return false;
  }


  @override
  Future<bool> checkUserExists({required String phone, required String email}) {
    return ds.checkUserIfExists(phone: phone, email: email);
  }           

  @override
  Stream<Either<AgentEntity, UserEntity>?>
  authStateChanges() => ds.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    try {
      // Try cache first, then network — avoids blocking on slow connections
      final getOptions = const GetOptions(source: Source.serverAndCache);

      final userDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get(getOptions)
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        return Right(UserEntity.fromMap(userDoc.data()!));
      }

      final agentDoc = await firestore
          .collection('agents')
          .doc(user.uid)
          .get(getOptions)
          .timeout(const Duration(seconds: 10));

      if (agentDoc.exists) {
        return Left(AgentEntity.fromMap(agentDoc.data()!));
      }
    } catch (_) {
      // Timeout or network error — fall through to default
    }

    // Authenticated but no Firestore record yet (new sign-up or fetch failed)
    return Right(
      UserEntity(
        gender: '',
        profileStatus: 'active',
        uid: user.uid,
        email: user.email ?? '',
        fullName: '',
        phone: '',
        profileImageUrl: '',
        agentId: '',
        userType: '',
        isProfileCreated: false,
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
    required String gender,

    required String email,
    required String password,
    required String agentId,
    required String phone,
  }) async {
    // show aget page

    // 3️⃣ create user (THIS WAS MISSING)
    await ds.signUpUserWithEmail(
      gender: gender,

      fullName: fullName,
      email: email,
      password: password,
      agentId: agentId,

      phone: phone,
    );
  }

  @override
  Future<void> logout() {
    return ds.logout();
  }
}
