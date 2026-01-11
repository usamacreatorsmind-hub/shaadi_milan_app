import '../../../../auth/domain/states/agent_state.dart';
 

abstract class AgentRepository {
  Future<AgentEntity> getAgentEntity(String uid);
  Stream<AgentEntity> watchAgent(String uid);
  Future<void> updateProfile(AgentEntity agent);
}
