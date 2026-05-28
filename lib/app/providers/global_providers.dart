import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';

final appRouterProvider = Provider((ref) => AppRouter(ref));

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProvider = Provider<User?>((ref) {
  return ref
      .watch(authStateChangesProvider)
      .when(
        data: (user) => user,
        loading: () => null,
        error: (error, stack) => null,
      );
});
final userDocProvider = StreamProvider.family<DocumentSnapshot?, String>((
  ref,
  uid,
) {
  return ref.watch(firestoreProvider).collection('users').doc(uid).snapshots();
});
final userRoleProvider = Provider<String?>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return null;
  final userDoc = ref
      .watch(userDocProvider(user.uid))
      .when(
        data: (doc) => doc,
        loading: () => null,
        error: (error, stack) => null,
      );
  return userDoc?.get('role');
});
