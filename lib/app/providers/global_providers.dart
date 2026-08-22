import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';

final appRouterProvider = Provider((ref) => AppRouter(ref));

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).when(data: (user) => user, loading: () => null, error: (error, stack) => null);
});
final userDocProvider = StreamProvider.family<DocumentSnapshot?, String>((ref, uid) {
  return ref.watch(firestoreProvider).collection('users').doc(uid).snapshots();
});
final userRoleProvider = Provider<String?>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return null;
  final userDoc = ref.watch(userDocProvider(user.uid)).when(data: (doc) => doc, loading: () => null, error: (error, stack) => null);
  return userDoc?.get('role');
});

/// Stores an override UID of the user whose profile is being created/edited.
/// Used by Agents when adding a new client.
final targetUserIdOverrideProvider = StateProvider<String?>((ref) => null);

/// Resolves the UID of the user whose profile is being created/edited.
/// Defaults to the currently logged-in user's UID unless overridden.
final targetUserIdProvider = Provider<String?>((ref) {
  final override = ref.watch(targetUserIdOverrideProvider);
  if (override != null) return override;

  final authUser = ref.watch(userProvider);
  return authUser?.uid;
});

final totalUnreadMessagesProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return Stream.value(0);

  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('chats').where('participants', arrayContains: user.uid).snapshots().map((snapshot) {
    int total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['unreadCount_${user.uid}'] as num? ?? 0).toInt();
    }
    return total;
  });
});
