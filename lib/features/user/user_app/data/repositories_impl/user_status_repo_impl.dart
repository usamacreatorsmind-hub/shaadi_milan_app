
import '../datasources/firebase/user_status_firestore.dart';
import '../../domain/repositories/user_status_repository.dart';
import '../../domain/states/user_status_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStatusRepositoryImpl implements UserStatusRepository {
  final UserStatusFirestore _userStatusFirestore;

  UserStatusRepositoryImpl(this._userStatusFirestore);

  @override
  Future<void> createUserStatus(String uid) {
    return _userStatusFirestore.updateUserStatus(uid, const UserStatus.empty());
  }

  @override
  Future<UserStatus> fetchUserStatus(String uid) {
    return _userStatusFirestore.fetchUserStatus(uid);
  }

  @override
  Stream<UserStatus> watchUserStatus(String uid) {
    return _userStatusFirestore.watchUserStatus(uid);
  }

  @override
  Future<void> updateUserStatus(String uid, UserStatus userStatus) {
    return _userStatusFirestore.updateUserStatus(uid, userStatus);
  }
}

final userStatusFirestoreProvider = Provider<UserStatusFirestore>((ref) {
  return UserStatusFirestore();
});

final userStatusRepositoryProvider = Provider<UserStatusRepository>((ref) {
  return UserStatusRepositoryImpl(ref.watch(userStatusFirestoreProvider));
});