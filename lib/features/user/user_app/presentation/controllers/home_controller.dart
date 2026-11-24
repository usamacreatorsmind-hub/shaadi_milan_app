import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final bool isLoadingMore;
  final bool hasMore;

  const HomeState({
    this.metrimonyProfiles = const AsyncValue.loading(),
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  HomeState copyWith({
    AsyncValue<List<MatrimonyProfileViewModel>>? metrimonyProfiles,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return HomeState(
      metrimonyProfiles: metrimonyProfiles ?? this.metrimonyProfiles,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
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

  // 🚀 In-memory caches to avoid redundant Firestore network reads and speed up loading
  final Map<String, UserEntity> _userCache = {};
  final Map<String, AgentEntity> _agentCache = {};

  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 30;

  HomeController({
    required MatrimonyRepository matrimonyRepository,
    required UserRepository userRepository,
    required AgentRepository agentRepository,
  }) : _matrimonyRepository = matrimonyRepository,
       _userRepository = userRepository,
       _agentRepository = agentRepository,
       super(const HomeState()) {
    loadInitialBatch();
  }

  Future<void> loadInitialBatch() async {
    _lastDocument = null;
    state = state.copyWith(metrimonyProfiles: const AsyncValue.loading(), hasMore: true, isLoadingMore: false);
    await fetchNextBatch();
  }

  Future<void> refreshAndShuffle() async {
    _lastDocument = null;
    state = state.copyWith(metrimonyProfiles: const AsyncValue.loading(), hasMore: true, isLoadingMore: false);
    await fetchNextBatch();
  }

  void shuffleCurrent() {
    final currentList = state.metrimonyProfiles.value;
    if (currentList != null && currentList.isNotEmpty) {
      final shuffled = List<MatrimonyProfileViewModel>.from(currentList)..shuffle(Random());
      state = state.copyWith(metrimonyProfiles: AsyncValue.data(shuffled));
    }
  }

  Future<void> fetchNextBatch() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final currentList = state.metrimonyProfiles.value ?? [];
    if (currentList.isNotEmpty) {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final res = await _matrimonyRepository.getMatrimonyProfilesBatch(
        limit: _pageSize,
        startAfter: _lastDocument,
      );

      _lastDocument = res.lastDoc;
      final profiles = res.profiles;

      final viewModels = await Future.wait(
        profiles.map((profile) async {
          UserEntity? user = _userCache[profile.userId];
          if (user == null || user.uid.isEmpty) {
            try {
              user = await _userRepository.fetchUser(profile.userId);
              if (user.uid.isNotEmpty) {
                _userCache[profile.userId] = user;
              }
            } catch (_) {
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

      final newItems = viewModels.whereType<MatrimonyProfileViewModel>().toList();
      // 🎲 Randomly shuffle profiles so different profiles appear at the top each time!
      newItems.shuffle(Random());
      final updatedList = [...currentList, ...newItems];

      debugPrint('Fetched batch of ${newItems.length} profiles. Total: ${updatedList.length}');
      state = state.copyWith(
        metrimonyProfiles: AsyncValue.data(updatedList),
        isLoadingMore: false,
        hasMore: res.lastDoc != null && profiles.length >= _pageSize,
      );
    } catch (e, st) {
      state = state.copyWith(
        metrimonyProfiles: currentList.isNotEmpty ? AsyncValue.data(currentList) : AsyncValue.error(e, st),
        isLoadingMore: false,
      );
    }
  }

  Future<MatrimonyProfile> getMatrimonyProfile(String uid) {
    return _matrimonyRepository.getMatrimonyProfile(uid);
  }
}
