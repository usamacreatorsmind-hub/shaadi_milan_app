import 'package:shadi_milan/core/notification/notification_service.dart';
import '../../data/repositories_impl/data_source/firebase_auth_ds.dart';
import '../../domain/states/agent_state.dart';
import '../../domain/states/user_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/global_providers.dart';
import '../../data/repositories_impl/auth_repo_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthDSProvider = Provider<FirebaseAuthDS>((ref) {
  return FirebaseAuthDS();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final ds = ref.watch(firebaseAuthDSProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthRepositoryImpl(ds, firestore);
});
 
final authStateProvider = StreamProvider<Either<AgentEntity, UserEntity>?>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  final stream = authRepository.authStateChanges();

  stream.listen((either) {
    either?.fold(
      (agent) => NotificationService.saveAdminTokenToFirestore(agent.uid),
      (user) => NotificationService.saveUserTokenToFirestore(user.uid),
    );
  });

  return stream;
});

/// Helper to invalidate auth cache after profile creation
/// Call: ref.invalidate(authStateProvider) to refresh user data from server
extension AuthStateInvalidator on WidgetRef {
  void invalidateAuthState() {
    invalidate(authStateProvider);
  }
}
