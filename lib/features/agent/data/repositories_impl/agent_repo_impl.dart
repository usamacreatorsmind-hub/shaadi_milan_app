// import '../../domain/states/agent_entity.dart';
// import '../../domain/repositories/agent_repository.dart';
// import '../datasources/agent_firestore_ds.dart';

// class AgentRepositoryImpl implements AgentRepository {
//   final AgentFirestoreDs ds;
//   AgentRepositoryImpl(this.ds);

//   @override
//   Future<AgentProfile> getAgentProfile(String uid) => ds.fetchProfile(uid);

//   @override
//   Stream<AgentProfile> watchAgent(String uid) => ds.watchProfile(uid);

//   @override
//   Future<void> updateProfile(AgentProfile agent) =>
//       ds.updateProfile(agent.uid, agent.toMap());
// }
