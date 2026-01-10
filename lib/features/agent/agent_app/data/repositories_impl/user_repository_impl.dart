import 'package:arvika_marriage_bureau/features/agent/agent_app/data/datasources/user_firestore.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/domain/repositories/user_repository.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
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
