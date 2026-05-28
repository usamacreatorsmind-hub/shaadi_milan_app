import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../auth/domain/states/agent_state.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../domain/repositories/agent_repository.dart';
import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  StreamSubscription? _usersSubscription;
  StreamSubscription? _profilesSubscription;

  List<UserEntity> _currentUsers = [];

  HomeController({
    required MatrimonyRepository matrimonyRepository,
    required UserRepository userRepository,
    required AgentRepository agentRepository,
  }) : _matrimonyRepository = matrimonyRepository,
       _userRepository = userRepository,
       _agentRepository = agentRepository,
       super(const HomeState()) {
    _watchData();
  }

  void _watchData() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      state = state.copyWith(metrimonyProfiles: const AsyncValue.data([]));
      return;
    }

    state = state.copyWith(metrimonyProfiles: const AsyncValue.loading());

    // Watch opposite gender users
    _usersSubscription = _userRepository
        .watchOppositeGenderUsers(currentUid)
        .listen(
          (users) {
            _currentUsers = users;
            _watchProfiles(users.map((u) => u.uid).toList());
          },
          onError: (e, st) {
            state = state.copyWith(metrimonyProfiles: AsyncValue.error(e, st));
          },
        );
  }

  void _watchProfiles(List<String> userIds) {
    _profilesSubscription?.cancel();

    if (userIds.isEmpty) {
      state = state.copyWith(metrimonyProfiles: const AsyncValue.data([]));
      return;
    }

    // Watch matrimony profiles for those users
    _profilesSubscription = _matrimonyRepository
        .watchMatrimonyProfilesForUsers(userIds)
        .listen(
          (profiles) async {
            try {
              final data = <MatrimonyProfileViewModel>[];

              for (final profile in profiles) {
                final user = _currentUsers.firstWhere(
                  (u) => u.uid == profile.userId,
                  orElse: () => UserEntity.empty(),
                );

                if (user.uid.isEmpty) continue;

                AgentEntity? agent;
                if (user.agentId.isNotEmpty) {
                  try {
                    agent = await _agentRepository.fetchAgent(user.agentId);
                  } catch (_) {}
                }

                data.add(
                  MatrimonyProfileViewModel(
                    profile: profile,
                    user: user,
                    agent: agent,
                  ),
                );
              }

              debugPrint('Fetched ${data.length} home profiles initially');
              for (final viewModel in data) {
                final profile = viewModel.profile;
                final user = viewModel.user;
                debugPrint(
                  'Home profile -> '
                  'name: ${user?.fullName ?? 'N/A'}, '
                  'uid: ${profile.userId}, '
                  'metrimonyId: ${profile.metrimonyId}, '
                  'profileId: ${profile.identity.profileId}, '
                  'gender: ${profile.identity.gender}, '
                  'state: ${profile.address.state}, '
                  'city: ${profile.address.city}',
                );
              }

              state = state.copyWith(metrimonyProfiles: AsyncValue.data(data));
            } catch (e, st) {
              state = state.copyWith(
                metrimonyProfiles: AsyncValue.error(e, st),
              );
            }
          },
          onError: (e, st) {
            state = state.copyWith(metrimonyProfiles: AsyncValue.error(e, st));
          },
        );
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _profilesSubscription?.cancel();
    super.dispose();
  }

  Future<MatrimonyProfile> getMatrimonyProfile(String uid) {
    return _matrimonyRepository.getMatrimonyProfile(uid);
  }
}
