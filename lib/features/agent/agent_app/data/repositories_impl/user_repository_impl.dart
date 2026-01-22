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

  // update status
   
  @override
  Future<void> updateUserStatus({
    required String userId,
    required String status,
    String? reason,
  }) {
    return userFirestore.updateUserStatus(
      userId: userId,
      status: status,
      reason: reason,
    );
  }
  


  @override
  Future<UserEntity> getUserById(String userId) {
    return userFirestore.getUserById(userId);
  }
  
  @override
  Future<void> closeMatrimonyProfile(String userId) {
    
    return userFirestore.closeMatrimonyProfile(userId);           

  }

  
}
