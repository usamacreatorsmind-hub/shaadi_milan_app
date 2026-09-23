import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';

import '../states/agent_state.dart';
import '../states/user_state.dart';

abstract class AuthRepository {
  User? get currentUser;

  Stream<Either<AgentEntity, UserEntity>?> authStateChanges();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signInAgentWithEmail(String email, String password);
  Future<void> signInUserWithEmail(String email, String password);
  Future<UserCredential> signInWithEmail(String email, String password);

  Future<void> signUpUserWithEmail({
    required BilingualValue fullName,
    required BilingualValue gender,

    required String email,
    required String password,
    required String agentId,
    required String phone,
  });

  Future<void> logout();

  Future<dynamic> checkPhoneAlreadyRegistered(String trim);
  Future<bool> checkUserExists({required String phone, required String email});

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  });

  Future<UserCredential> signInWithPhoneCredential(
    String verificationId,
    String smsCode,
  );

  Future<void> updatePassword(String newPassword);

  Future<Map<String, dynamic>> sendMSG91OTP(String phone);
  Future<Map<String, dynamic>> verifyMSG91OTP(String phone, String otp);
}
