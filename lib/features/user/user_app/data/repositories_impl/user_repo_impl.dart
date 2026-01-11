import '../../domain/states/user_status_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/states/address_state.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../datasources/firebase/user_firestore_ds.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirestoreDS _ds;

  UserRepositoryImpl(this._ds);
  @override
  Future<List<UserEntity>> fetchUsers() async {
    final data = await _ds.fetchUsers();
    return data.map((e) => UserEntity.fromMap(e)).toList();
  }

  @override
  Stream<UserEntity> watchUser(String uid) {
    return _ds.watchUser(uid).map((data) => UserEntity.fromMap(data));
  }

  @override
  Future<void> updateUser(String uid, UserEntity user) {
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
  Future<UserEntity> fetchUser(String uid) async {
    final data = await _ds.fetchUser(uid);
    return UserEntity.fromMap(data);
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

  @override
  Future<void> updateProfilePhoto(String uid, String profilePhotoUrl) {
    return _ds.updateField(uid, 'profilePhoto', profilePhotoUrl);
  }

  @override
  Future<void> addWishlist(String uid, String profileId) {
    return _ds.addWishlist(uid, profileId);
  }

  @override
  Future<void> removeWishlist({
    required String uid,
    required String profileId,
  }) {
    return _ds.removeWishlist(uid, profileId);
  }

  @override
  Future<UserStatus> fetchUserStatus(String uid) async {
    final data = await _ds.fetchUser(uid);
    return UserStatus.fromMap(data['userStatus']);
  }

  @override
  Future<void> updateUserStatus(String uid, UserStatus userStatus) {
    return _ds.updateField(uid, 'userStatus', userStatus.toMap());
  }

  @override
  Stream<UserStatus> watchUserStatus(String uid) {
    return _ds
        .watchUser(uid)
        .map((data) => UserStatus.fromMap(data['userStatus']));
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final userFirestoreDS = ref.read(userFirestoreDSProvider);
  return UserRepositoryImpl(userFirestoreDS);
});

final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (eitherUser) {
      if (eitherUser == null) {
        return const Stream.empty();
      }

      return eitherUser.fold(
        (agent) => const Stream.empty(),
        (user) => ref.watch(userRepositoryProvider).watchUser(user.uid),
      );
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final currentUserProfileProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return authState.when(
    data: (eitherUser) {
      if (eitherUser == null) {
        return Stream.value(null);
      }
      return eitherUser.fold(
        (agent) => Stream.value(null),
        (user) => userRepository.watchUser(user.uid),
      );
    },
    loading: () => Stream.value(null),
    error: (error, stackTrace) => Stream.value(null),
  );
});
