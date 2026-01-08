import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/global_providers.dart';
import '../../../user_app/domain/states/user_state.dart';
import '../../data/datasources/firebase_auth_ds.dart';
import '../../data/repositories_impl/auth_repo_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthDSProvider = Provider<FirebaseAuthDS>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return FirebaseAuthDS(auth: firebaseAuth, firestore: firestore);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final ds = ref.watch(firebaseAuthDSProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRepositoryImpl(ds, firestore);
});

/// Provides the current [AppUser] object (logged in) or null (logged out).
/// This stream combines Firebase Auth state with user data from Firestore.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Helper to invalidate auth cache after profile creation
/// Call: ref.invalidate(authStateProvider) to refresh user data from server
extension AuthStateInvalidator on WidgetRef {
  void invalidateAuthState() {
    invalidate(authStateProvider);
  }
}
