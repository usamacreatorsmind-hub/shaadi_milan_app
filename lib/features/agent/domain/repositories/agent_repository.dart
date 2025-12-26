import '../../../user/user_app/domain/states/agent_state.dart';

import '../states/agent_entity.dart';

abstract class AgentRepository {
  Future<AgentProfile> getAgentProfile(String uid);
  Stream<AgentProfile> watchAgent(String uid);
  Future<void> updateProfile(AgentProfile agent);
}
