import '../../../../auth/domain/states/user_state.dart';

abstract class UserRepository {
  Future<UserEntity> getUserById(String userId);
  Future<List<UserEntity>> getUsersForAgent(String agentId);
  // update wishlist status

  Future<void> updateUserStatus({
    required String userId,
    required String status,
    String? reason,
  }); 
}
