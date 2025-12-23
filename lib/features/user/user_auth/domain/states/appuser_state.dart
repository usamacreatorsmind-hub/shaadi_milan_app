
import '../../../user_app/domain/states/user_state.dart';
 

class AppUserState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AppUserState({this.user, this.isLoading = false, this.error});

  AppUserState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AppUserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = AppUserState(
    user: null,
    isLoading: false,
    error: null,
  );
}