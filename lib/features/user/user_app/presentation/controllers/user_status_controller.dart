import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_status_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/user_status_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/states/user_status_state.dart';

class UserStatusController extends StateNotifier<UserStatusState> {
  final UserStatusRepository _userStatus;
  final String _uid;

  UserStatusController(this._userStatus, this._uid)
    : super(UserStatusState.initial) {
    _watchUserStatus();
  }

  void _watchUserStatus() {
    _userStatus
        .watchUserStatus(_uid)
        .listen(
          (userStatus) {
            state = state.copyWith(userStatus: userStatus, isLoading: false);
          },
          onError: (e) {
            state = state.copyWith(isLoading: false, error: e.toString());
          },
        );
  }
}

final userStatusControllerProvider =
    StateNotifierProvider<UserStatusController, UserStatusState>((ref) {
      final userRepository = ref.read(userStatusRepositoryProvider);
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }
      return UserStatusController(userRepository, uid);
    });
