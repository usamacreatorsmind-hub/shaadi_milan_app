import '../states/agent_entity.dart';

abstract class AgentRepository {
  Future<AgentProfile> getAgentProfile(String uid);
  Stream<AgentProfile> watchAgent(String uid);
  Future<void> updateProfile(AgentProfile agent);
}
