import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/user_status_repository.dart';
import '../../domain/states/user_status_state.dart';
import '../datasources/firebase/user_status_firestore.dart';

class UserStatusRepositoryImpl implements UserStatusRepository {
  final UserStatusFirestoreDS _remoteDS;

  UserStatusRepositoryImpl(this._remoteDS);

  @override
  Future<void> createUserStatus(String uid) {
    return _remoteDS.createUserStatus(uid);
  }

  @override
  Future<void> markProfileCreated(String uid) {
    return _remoteDS.markProfileCreated(uid);
  }

  @override
  Future<void> deleteUserStatus(String uid) {
    return _remoteDS.deleteUserStatus(uid);
  }

  @override
  Future<UserStatus> getUserStatus(String uid) {
    return _remoteDS.getUserStatus(uid);
  }

  @override
  Future<void> updateUserStatus(String uid, UserStatus userStatus) {
    return _remoteDS.updateUserStatus(uid, userStatus);
  }

  @override
  Stream<UserStatus> watchUserStatus(String uid) {
    return _remoteDS.watchUserStatus(uid);
  }
}

final userStatusFirestoreDSProvider = Provider<UserStatusFirestoreDS>((ref) {
  return UserStatusFirestoreDS();
});

final userStatusRepositoryProvider = Provider<UserStatusRepository>((ref) {
  return UserStatusRepositoryImpl(ref.watch(userStatusFirestoreDSProvider));
});
final userStatusStreamProvider = StreamProvider.family<UserStatus, String>((
  ref,
  uid,
) {
  return ref.read(userStatusRepositoryProvider).watchUserStatus(uid);
});
