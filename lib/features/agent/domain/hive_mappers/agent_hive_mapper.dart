 

import 'package:arvika_marriage_bureau/features/agent/domain/hive_entities/agent_entity_hive.dart';
import 'package:arvika_marriage_bureau/features/agent/domain/states/agent_entity.dart';

class AgentHiveMapper {
  // Hive → Domain
  static AgentProfile toDomain(AgentEntityHive hive) {
    return AgentProfile(
      agentId: hive.agentId,
      agentName: hive.agentName, 
      agentMobile: hive.agentMobile,
      
      registrationDate: hive.registrationDate,
      role: hive.role,
      uid: hive.uid,
      email: hive.email,
      photoUrl: hive.photoUrl,
    );
  }

  // Domain → Hive
  static AgentEntityHive toHive(AgentProfile domain) {
    return AgentEntityHive(
      agentId: domain.agentId,
      agentName: domain.agentName,
      agentMobile: domain.agentMobile,
      
      registrationDate: domain.registrationDate,
      role: domain.role,
      uid: domain.uid,
      email: domain.email,
      photoUrl: domain.photoUrl,
    );
  }
}
