import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/domain/states/agent_state.dart';
import '../../domain/repositories/agent_repository.dart';
import '../datasources/firebase/agent_firestore_ds.dart';

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return AgentRepositoryImpl(ref.watch(agentFirestoreDsProvider));
});

class AgentRepositoryImpl implements AgentRepository {
  final AgentFirestoreDs _firestore;

  AgentRepositoryImpl(this._firestore);

  @override
  Future<AgentEntity> getAgentEntity(String agentId) async {
    final agent = await _firestore.fetchAgentByUid(agentId);
    return agent;
  }

  @override
  Future<AgentEntity> fetchAgentEntitybyAgentId(String agentId) async {
    final agent = await _firestore.fetchAgentbyAgentId(agentId);
    return agent;
  }

  @override
  Future<String> fetchAgentUidbyAgentId(String agentId) async {
    final agentUid = await _firestore.fetchAgentDocIdByAgentId(
      agentId: agentId,
    );
    if (agentUid == null) {
      throw Exception('Agent with ID $agentId not found');
    }
    return agentUid;
  }

  @override
  Future<void> updateProfile(AgentEntity agent) {
    throw UnimplementedError();
  }

  @override
  Stream<AgentEntity> watchAgent(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<AgentEntity> fetchAgent(String uid) {
    final agent = _firestore.fetchAgentByUid(uid);
    return agent;
  }
}
