import 'package:firebase_auth/firebase_auth.dart';

import '../../../user_app/domain/states/user_state.dart';

abstract class AuthRepository {
  User? get currentUser => null;

  Stream<AppUser?> authStateChanges();
  Future<void> signUpWithEmail(
  // ADD NAMED PARAMETER
  {
    required String fullName,
    required String email,
    required String password,
    required String agentId,
    required String phone, 
  });
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<bool> checkUserIfExists();

  Future<void> sendPasswordResetEmail(String trim) async {}
}
