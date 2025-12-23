import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/matrimony_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/metrimony_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class UserHomeState {
  final AsyncValue<List<MatrimonyProfile>> newMembers;
  final AsyncValue<List<MatrimonyProfile>> metrimonyProfiles;

  const UserHomeState({
    this.newMembers = const AsyncValue.loading(),
    this.metrimonyProfiles = const AsyncValue.loading(),
  });

  UserHomeState copyWith({
    AsyncValue<List<MatrimonyProfile>>? newMembers,
    AsyncValue<List<MatrimonyProfile>>? metrimonyProfiles,
  }) {
    return UserHomeState(
      newMembers: newMembers ?? this.newMembers,
      metrimonyProfiles: metrimonyProfiles ?? this.metrimonyProfiles,
    );
  }
}

class UserHomeController extends StateNotifier<UserHomeState> {
  final MatrimonyRepository _repository;

  UserHomeController(this._repository) : super(const UserHomeState()) {
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([_fetchNewMembers(), _fetchRecommendedMatches()]);
  }

  Future<void> _fetchNewMembers() async {
    try {
      final members = await _repository.getAllMatrimonyProfiles();
      state = state.copyWith(newMembers: AsyncValue.data(members));
    } catch (e, st) {
      state = state.copyWith(newMembers: AsyncValue.error(e, st));
    }
  }

  // fetch profile form server for details

  Future<MatrimonyProfile> getMatrimonyProfile(String uid) async {
    return _repository.getMatrimonyProfile(uid);
  }

  Future<void> _fetchRecommendedMatches() async {
    try {
      final matches = await _repository.getAllMatrimonyProfiles();
      state = state.copyWith(metrimonyProfiles: AsyncValue.data(matches));
    } catch (e, st) {
      state = state.copyWith(metrimonyProfiles: AsyncValue.error(e, st));
    }
  }
}

final userHomeControllerProvider =
    StateNotifierProvider<UserHomeController, UserHomeState>((ref) {
      final repository = ref.watch(matrimonyRepositoryProvider);
      return UserHomeController(repository);
    });
