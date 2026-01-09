import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/agent_repository.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/user_repository.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/metrimony_state.dart';

class HomeState {
  final AsyncValue<List<MatrimonyProfileViewModel>> metrimonyProfiles;

  const HomeState({this.metrimonyProfiles = const AsyncValue.loading()});
  HomeState copyWith({
    AsyncValue<List<MatrimonyProfileViewModel>>? metrimonyProfiles,
  }) {
    return HomeState(
      metrimonyProfiles: metrimonyProfiles ?? this.metrimonyProfiles,
    );
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    final matrimonyRepository = ref.read(matrimonyRepositoryProvider);
    final userRepository = ref.read(userRepositoryProvider);
    final agentRepository = ref.read(agentRepositoryProvider);

    return HomeController(
      matrimonyRepository: matrimonyRepository,
      userRepository: userRepository,
      agentRepository: agentRepository,
    );
  },
);

class HomeController extends StateNotifier<HomeState> {
  final MatrimonyRepository _matrimonyRepository;
  final UserRepository _userRepository;
  final AgentRepository _agentRepository;

  HomeController({
    required MatrimonyRepository matrimonyRepository,
    required UserRepository userRepository,
    required AgentRepository agentRepository,
  }) : _matrimonyRepository = matrimonyRepository,
       _userRepository = userRepository,
       _agentRepository = agentRepository,
       super(const HomeState()) {
    _loadData();
  }
  Future<void> _loadData() async {
    try {
      state = state.copyWith(metrimonyProfiles: const AsyncValue.loading());

      final profiles = await _matrimonyRepository.getAllMatrimonyProfiles();
      final users = await _userRepository.fetchUsers();

      final data = await Future.wait(
        profiles.map((profile) async {
          final user = users.firstWhere(
            (u) => u.uid == profile.userId,
            orElse: () => UserEntity.empty(),
          );

          AgentEntity? agent;
          if (profile.agentId.isNotEmpty) {
            agent = await _agentRepository.fetchAgent(profile.agentId);
          }

          return MatrimonyProfileViewModel(
            profile: profile,
            user: user,
            agent: agent,
          );
        }),
      );

      state = state.copyWith(metrimonyProfiles: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(metrimonyProfiles: AsyncValue.error(e, st));
    }
  }

  Future<MatrimonyProfile> getMatrimonyProfile(String uid) {
    return _matrimonyRepository.getMatrimonyProfile(uid);
  }
}
