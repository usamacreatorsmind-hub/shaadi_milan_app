import 'dart:async';
import '../../../user_app/domain/states/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Stream<AppUser?> authStateChanges() => _authRepository.authStateChanges();

  // Expose authentication changes as a Stream

  Future<bool> checkUserIfExists(String email) async {
    return await _authRepository.checkUserIfExists();
  }

  Future<void> signUpWithEmail(
    String fullName,
    String email,
    String password,
    String agentId,
    String phone,
  ) async {
    await _authRepository.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
      agentId: agentId,
      phone: phone, 
    );
 
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _authRepository.signInWithEmail(email, password);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
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
}

final authControllerProvider = StateNotifierProvider<AuthController, User?>((
  ref,
) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthController(authRepository);
});
