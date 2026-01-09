import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
 

abstract class AgentRepository {
  Future<AgentEntity> fetchAgent(String uid);
  Future<AgentEntity> fetchAgentEntitybyAgentId(String agentId);
  Future<String> fetchAgentUidbyAgentId(String agentId);
}
