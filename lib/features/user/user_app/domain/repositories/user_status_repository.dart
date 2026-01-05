 

import '../states/user_status_state.dart';

abstract class UserStatusRepository {
  Future<void> createUserStatus(String uid);
  Future<UserStatus> fetchUserStatus(String uid);
  Stream<UserStatus> watchUserStatus(String uid);
  Future<void> updateUserStatus(String uid, UserStatus userStatus);
}
