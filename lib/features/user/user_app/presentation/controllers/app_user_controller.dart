import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/states/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AppUserController extends StateNotifier<AsyncValue<AppUser?>> {
  final UserRepository _userRepository;
  final String _uid;

  AppUserController(this._userRepository, this._uid)
    : super(const AsyncValue.loading()) {
    _userRepository
        .watchUser(_uid)
        .listen(
          (user) {
            state = AsyncValue.data(user);
          },
          onError: (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          },
        );
  }

  Future<void> updateProfileId(String profileId) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateProfileId(_uid, profileId);
      state = AsyncValue.data(state.value?.copyWith(profileId: profileId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAgentId(String agentId) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateAgentId(_uid, agentId);
      state = AsyncValue.data(state.value?.copyWith(agentId: agentId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePhone(String phone) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updatePhone(_uid, phone);
      state = AsyncValue.data(state.value?.copyWith(phone: phone));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRole(String role) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateRole(_uid, role);
      state = AsyncValue.data(state.value?.copyWith(role: role));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateFullName(String fullName) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateFullName(_uid, fullName);
      state = AsyncValue.data(state.value?.copyWith(fullName: fullName));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateEmail(_uid, email);
      state = AsyncValue.data(state.value?.copyWith(email: email));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final appUserControllerProvider =
    StateNotifierProvider.family<
      AppUserController,
      AsyncValue<AppUser?>,
      String
    >((ref, uid) {
      final userRepository = ref.read
      (userRepositoryProvider);
      return AppUserController(userRepository, uid);
    });
