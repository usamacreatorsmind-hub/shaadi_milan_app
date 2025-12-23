// import '../../../../app/providers/global_providers.dart';
// import '../../data/repositories_impl/agent_repo_impl.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod/src/framework.dart';
// import '../../domain/states/agent_entity.dart';
// import '../../data/datasources/agent_firestore_ds.dart';
// import '../../domain/repositories/agent_repository.dart';

// final agentFirestoreDSProvider = Provider(
//   (ref) => AgentFirestoreDs(ref.read(firestoreProvider)),
// );
// final agentRepoProvider = Provider<AgentRepository>(
//   (ref) => AgentRepositoryImpl(ref.read(agentFirestoreDSProvider)),
// );

// final userProfileController = StreamProvider.family<AgentProfile, String>((
//   ref,
//   uid,
// ) {
//   final repo = ref.read(agentRepoProvider);
//   return repo.watchAgent(uid);
// });
