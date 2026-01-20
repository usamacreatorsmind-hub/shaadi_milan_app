import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    required String fullName,
    required String gender,
    

    required String email,
    required String password,
    required String agentId,
    required String phone,
    required List<WishListItem> wishlists,
  });

  Future<void> logout();
}
