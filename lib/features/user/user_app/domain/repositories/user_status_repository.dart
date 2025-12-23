import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/user_status_state.dart';

import 'metrimony_repository.dart';

abstract class UserStatusRepository {
  Future<void> createUserStatus(String uid);
  Future<void> updateUserStatus(String uid, UserStatus userStatus);
  Future<void> deleteUserStatus(String uid);
  Future<UserStatus> getUserStatus(String uid);
  Stream<UserStatus> watchUserStatus(String uid);
  Future<void> markProfileCreated(String uid);
}
