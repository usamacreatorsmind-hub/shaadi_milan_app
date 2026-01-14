import '../../../../auth/domain/states/user_state.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirestore userFirestore;

  UserRepositoryImpl({required this.userFirestore});

  @override
  Future<List<UserEntity>> getUsersForAgent(String agentId) {
    return userFirestore.getUsersForAgent(agentId);
  }

  @override
  Future<UserEntity> getUserById(String userId) {
    return userFirestore.getUserById(userId);
  }
}
