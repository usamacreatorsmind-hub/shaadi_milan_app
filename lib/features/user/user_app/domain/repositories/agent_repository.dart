import 'package:arvika_marriage_bureau/features/agent/domain/states/agent_entity.dart';

abstract class AgentRepository {
  Future<AgentProfile> fetchAgent(String uid);
}
