import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/global_providers.dart';
import '../../../user_app/domain/states/user_state.dart';
import '../../data/datasources/firebase_auth_ds.dart';
import '../../data/repositories_impl/auth_repo_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthDSProvider = Provider<FirebaseAuthDS>((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  final firestore = ref.read(firestoreProvider);
  return FirebaseAuthDS(auth: firebaseAuth, firestore: firestore);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final ds = ref.read(firebaseAuthDSProvider);
  final firestore = ref.read(firestoreProvider);
  return AuthRepositoryImpl(ds, firestore);
});

/// Provides the current [AppUser] object (logged in) or null (logged out).
/// This stream combines Firebase Auth state with user data from Firestore.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});
