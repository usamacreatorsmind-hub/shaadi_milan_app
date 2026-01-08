import '../states/agent_state.dart';

abstract class AgentRepository {
  Future<AgentProfile> fetchAgent(String uid);
  Future<AgentProfile> fetchAgentProfilebyAgentId(String agentId);
  Future<String> fetchAgentUidbyAgentId(String agentId);
  

}
