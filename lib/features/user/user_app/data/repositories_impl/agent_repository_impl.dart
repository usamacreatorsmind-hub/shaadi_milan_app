import '../datasources/firebase/agent_firestore_ds.dart';
import '../../domain/repositories/agent_repository.dart';
import '../../domain/states/agent_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return AgentRepositoryImpl(ref.watch(agentFirestoreDsProvider));
});

class AgentRepositoryImpl implements AgentRepository {
  final AgentFirestoreDs _firestore;

  AgentRepositoryImpl(this._firestore);

  @override
  Future<AgentProfile> getAgentProfile(String agentId) async {
    final agentProfile = await _firestore.fetchAgentByUid(agentId);
    return agentProfile;
  }

  @override
  Future<AgentProfile> fetchAgentProfilebyAgentId(String agentId) async {
    final agentProfile = await _firestore.fetchAgentbyAgentId(agentId);
    return agentProfile;
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
  Future<void> updateProfile(AgentProfile agent) {
    throw UnimplementedError();
  }

  @override
  Stream<AgentProfile> watchAgent(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<AgentProfile> fetchAgent(String uid) {
    final agentProfile = _firestore.fetchAgentByUid(uid);
    return agentProfile;
  }
}
