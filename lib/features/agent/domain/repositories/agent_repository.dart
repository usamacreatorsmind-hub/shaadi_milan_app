import '../../../user/user_app/domain/states/agent_state.dart';


abstract class AgentRepository {
  Future<AgentProfile> getAgentProfile(String uid);
  Stream<AgentProfile> watchAgent(String uid);
  Future<void> updateProfile(AgentProfile agent);
}
