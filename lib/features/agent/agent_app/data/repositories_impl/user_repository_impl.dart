import '../datasources/user_firestore.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../../auth/domain/states/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
