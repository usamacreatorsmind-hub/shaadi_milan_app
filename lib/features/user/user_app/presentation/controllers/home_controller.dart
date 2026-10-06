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
  HomeState copyWith({AsyncValue<List<MatrimonyProfileViewModel>>? metrimonyProfiles}) {
    return HomeState(metrimonyProfiles: metrimonyProfiles ?? this.metrimonyProfiles);
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  final matrimonyRepository = ref.read(matrimonyRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  final agentRepository = ref.read(agentRepositoryProvider);

  return HomeController(matrimonyRepository: matrimonyRepository, userRepository: userRepository, agentRepository: agentRepository);
});

class HomeController extends StateNotifier<HomeState> {
  final MatrimonyRepository _matrimonyRepository;
  final UserRepository _userRepository;
  final AgentRepository _agentRepository;
  StreamSubscription? _usersSubscription;
  StreamSubscription? _profilesSubscription;

  // 🚀 In-memory caches to avoid redundant Firestore network reads and speed up loading
  final Map<String, UserEntity> _userCache = {};
  final Map<String, AgentEntity> _agentCache = {};

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

    // Fetch directly from metrimony_profiles with cached user/agent mapping
    _profilesSubscription = _matrimonyRepository.watchAllMatrimonyProfiles().listen(
      (profiles) async {
        try {
          // Parallelize data fetching with in-memory caching for blazing fast performance
          final data = await Future.wait(
            profiles.map((profile) async {
              UserEntity? user = _userCache[profile.userId];
              if (user == null || user.uid.isEmpty) {
                try {
                  user = await _userRepository.fetchUser(profile.userId);
                  if (user.uid.isNotEmpty) {
                    _userCache[profile.userId] = user;
                  }
                } catch (e) {
                  user = UserEntity.empty();
                }
              }

              if (user == null || user.uid.isEmpty) return null;

              AgentEntity? agent;
              if (user.agentId.isNotEmpty) {
                agent = _agentCache[user.agentId];
                if (agent == null) {
                  try {
                    agent = await _agentRepository.fetchAgent(user.agentId);
                    if (agent != null) {
                      _agentCache[user.agentId] = agent;
                    }
                  } catch (_) {}
                }
              }

              return MatrimonyProfileViewModel(profile: profile, user: user, agent: agent);
            }),
          );

          // Remove nulls (skipped users)
          final filteredData = data.whereType<MatrimonyProfileViewModel>().toList();

          debugPrint('Fetched ${filteredData.length} home profiles with caching');
          state = state.copyWith(metrimonyProfiles: AsyncValue.data(filteredData));
        } catch (e, st) {
          state = state.copyWith(metrimonyProfiles: AsyncValue.error(e, st));
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
