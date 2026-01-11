import '../../../../auth/domain/states/user_state.dart';

abstract class UserRepository {
  Future<UserEntity> getUserById(String userId);
  Future<List<UserEntity>> getUsersForAgent(String agentId);
}
