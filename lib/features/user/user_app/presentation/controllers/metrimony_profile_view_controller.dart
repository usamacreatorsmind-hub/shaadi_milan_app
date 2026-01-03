// import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/user_firestore_ds.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/agent_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/user_state.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';

// import '../../domain/repositories/metrimony_repository.dart';
// import '../../domain/states/metrimony_state.dart';
// import '../../data/repositories_impl/matrimony_repository_impl.dart';

// class MatrimonyProfileViewController
//     extends StateNotifier<MetrimonyProfileViewModelState> {
//   final MatrimonyRepository _matrimonyRepository;
//   final Ref ref;

//   MatrimonyProfileViewController(this._matrimonyRepository, this.ref)
//     : super(MetrimonyProfileViewModelState.initial());

//   Future<void> getMatrimonyProfileViewModel(String uid) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final matrimonyProfile = await _matrimonyRepository.getMatrimonyProfile(
//         uid,
//       );
//       // Assuming you have a way to get AppUser and AgentProfile based on the matrimonyProfile
//       // For now, let's use dummy data or fetch them if available
//       // You'll need to implement the actual fetching logic for AppUser and AgentProfile
//       // based on matrimonyProfile.userId and matrimonyProfile.agentId
//       final userId = matrimonyProfile.userId; // This needs to be fetched
//       final agentId = matrimonyProfile.agentId; // This needs to be fetched

//       // fetch agent profile and user profile using ids available in matrimony profile using specific repository methods
//       final userRepository = ref.read(userRepositoryProvider);
//       final fetchedUserProfile = await userRepository.fetchUser(userId);
//       final agentRepository = ref.read(agentRepositoryProvider);
//       final fetchedAgentProfile = await agentRepository
//           .fetchAgentProfilebyAgentId(agentId);

//       final viewModel = MetrimonyProfileViewModel(
//         metrimonyProfile: matrimonyProfile,
//         userProfile: fetchedUserProfile,
//         agentProfile: fetchedAgentProfile,
//       );
//       state = state.copyWith(
//         matrimonyProfileViewModel: viewModel,
//         isLoading: false,
//       );
//     } catch (e, st) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }
// }

// final matrimonyProfileViewProvider =
//     StateNotifierProvider<
//       MatrimonyProfileViewController,
//       MetrimonyProfileViewModelState
//     >((ref) {
//       final matrimonyRepository = ref.watch(matrimonyRepositoryProvider);
//       return MatrimonyProfileViewController(matrimonyRepository, ref);
//     });
