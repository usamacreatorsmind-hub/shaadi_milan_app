import '../../domain/repositories/user_repository.dart';
import '../../domain/states/address_state.dart';
import '../../domain/states/user_state.dart';
import '../../../user_auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/firebase/user_firestore_ds.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirestoreDS _ds;

  UserRepositoryImpl(this._ds);

  @override
  Stream<AppUser> watchUser(String uid) {
    return _ds.watchUser(uid).map((data) => AppUser.fromMap(data));
  }

  @override
  Future<void> updateUser(String uid, AppUser user) {
    return _ds.updateUser(uid, user.toMap());
  }

  @override
  Future<void> updateField(String uid, String fieldPath, dynamic value) {
    return _ds.updateField(uid, fieldPath, value);
  }

  @override
  Future<void> deleteUser(String uid) {
    return _ds.deleteUser(uid);
  }

  @override
  Future<AppUser> fetchUser(String uid) async {
    final data = await _ds.fetchUser(uid);
    return AppUser.fromMap(data);
  }

  @override
  Future<void> updateProfileId(String uid, String profileId) {
    return _ds.updateField(uid, 'profileId', profileId);
  }

  @override
  Future<void> updateAgentId(String uid, String agentId) {
    return _ds.updateField(uid, 'agentId', agentId);
  }

  @override
  Future<void> updatePhone(String uid, String phone) {
    return _ds.updateField(uid, 'phone', phone);
  }

  @override
  Future<void> updateRole(String uid, String role) {
    return _ds.updateField(uid, 'role', role);
  }

  @override
  Future<void> updateFullName(String uid, String fullName) {
    return _ds.updateField(uid, 'fullName', fullName);
  }

  @override
  Future<void> updateEmail(String uid, String email) {
    return _ds.updateField(uid, 'email', email);
  }

  @override
  Future<void> updatePassword(String uid, String password) {
    // This should ideally be    // handled by FirebaseAuth, not directly by Firestore.
    // If you need to update the password, it should be done via FirebaseAuth.
    throw UnimplementedError('Password updates are handled by FirebaseAuth.');
  }

  @override
  Future<void> updateAddress(String uid, AddressProfile address) {
    return _ds.updateField(uid, 'address', address.toMap());
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final userFirestoreDS = ref.read(userFirestoreDSProvider);
  return UserRepositoryImpl(userFirestoreDS);
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return const Stream.empty();
      }

      final repo = ref.read(userRepositoryProvider);
      return repo.watchUser(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
