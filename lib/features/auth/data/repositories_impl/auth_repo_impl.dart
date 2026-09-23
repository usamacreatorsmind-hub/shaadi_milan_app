import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/states/agent_state.dart';
import '../../domain/states/user_state.dart';
import 'data_source/firebase_auth_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDS ds;
  final FirebaseFirestore firestore;
  AuthRepositoryImpl(this.ds, this.firestore);

  @override
  User? get currentUser => ds.currentUser;

  @override
  Future<dynamic> checkPhoneAlreadyRegistered(String phone) async {
    final usersQuery = await firestore.collection('users').where('phone', isEqualTo: phone).get();
    if (usersQuery.docs.isNotEmpty) {
      return true;
    }

    final agentsQuery = await firestore.collection('agents').where('phone', isEqualTo: phone).get();
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
  Stream<Either<AgentEntity, UserEntity>?> authStateChanges() => ds.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    try {
      // Try cache first, then network — avoids blocking on slow connections
      final getOptions = const GetOptions(source: Source.serverAndCache);

      final userDoc = await firestore.collection('users').doc(user.uid).get(getOptions).timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        return Right(UserEntity.fromMap(userDoc.data()!));
      }

      final agentDoc = await firestore.collection('agents').doc(user.uid).get(getOptions).timeout(const Duration(seconds: 10));

      if (agentDoc.exists) {
        return Left(AgentEntity.fromMap(agentDoc.data()!));
      }
    } catch (_) {
      // Timeout or network error — fall through to default
    }

    // Authenticated but no Firestore record yet (new sign-up or fetch failed)
    return Right(
      UserEntity(
        gender: BilingualValue.empty(),
        profileStatus: 'active',
        uid: user.uid,
        email: user.email ?? '',
        fullName: BilingualValue(hi: '', en: user.displayName ?? ''),
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
    required BilingualValue fullName,
    required BilingualValue gender,

    required String email,
    required String password,
    required String agentId,
    required String phone,
  }) async {
    // show aget page

    // 3️⃣ create user (THIS WAS MISSING)
    await ds.signUpUserWithEmail(gender: gender, fullName: fullName, email: email, password: password, agentId: agentId, phone: phone);
  }

  @override
  Future<void> logout() {
    return ds.logout();
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) {
    return ds.verifyPhoneNumber(phoneNumber: phoneNumber, onCodeSent: onCodeSent, onVerificationFailed: onVerificationFailed);
  }

  @override
  Future<UserCredential> signInWithPhoneCredential(String verificationId, String smsCode) {
    return ds.signInWithPhoneCredential(verificationId, smsCode);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return ds.updatePassword(newPassword);
  }

  @override
  Future<Map<String, dynamic>> sendMSG91OTP(String phone) async {
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('sendMSG91OTP').call({
        'phoneNumber': phone,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyMSG91OTP(String phone, String otp) async {
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('verifyMSG91OTP').call({
        'phoneNumber': phone,
        'otp': otp,
      });
      
      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['success'] == true && data['verified'] == true && data['registered'] == true) {
        final customToken = data['customToken'] as String;
        await FirebaseAuth.instance.signInWithCustomToken(customToken);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
