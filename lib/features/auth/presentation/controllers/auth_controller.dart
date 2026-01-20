import 'dart:async';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/states/agent_state.dart';
import '../providers/auth_providers.dart';
import 'package:dartz/dartz.dart';

import '../../../auth/domain/states/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthController extends StateNotifier<User?> {
  bool isProfileCreated = false;
  bool isApproved = false;
  bool isRejected = false;

  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  AuthController(this._authRepository) : super(_authRepository.currentUser) {
    _authStateSubscription = _authRepository.authStateChanges().listen((_) {
      state = _authRepository.currentUser;
    });
  }

  Stream<Either<AgentEntity, UserEntity>?> authStateChanges() =>
      _authRepository.authStateChanges();

  Future<void> signUpWithEmail(
    String fullName,
    String email,
    String password,
    String agentId,
    String gender,
    String phone,
  ) async {
    await _authRepository.signUpUserWithEmail(
      gender: gender,
      
      fullName: fullName,
      email: email,
      password: password,
      agentId: agentId,
      phone: phone,
      wishlists: [],
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _authRepository.signInUserWithEmail(email, password);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();

    // navigate to onboarding
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Get firebase userId

  String? get currentUserId => state?.uid;

  Stream<bool> get isAuthenticated =>
      _authRepository.authStateChanges().map((user) => user != null);

  void logout() {
    _authRepository.signOut();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, User?>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});
