import 'package:firebase_auth/firebase_auth.dart';

import '../../../user_app/domain/states/user_state.dart';
 

abstract class AuthRepository {
  User? get currentUser => null;

  Stream<AppUser?> authStateChanges();
  Future<void> signUpWithEmail(
    String fullName,
    String email,
    String password,
    String agentId,
    String phone,
    
  );
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<bool> checkUserIfExists();
}
