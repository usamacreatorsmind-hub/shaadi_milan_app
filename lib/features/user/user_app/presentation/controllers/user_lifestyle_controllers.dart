import '../../domain/repositories/metrimony_repository.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import 'metrimony_profile_controller.dart';
import '../../domain/states/lifestyle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class UserLifestyleController extends StateNotifier<LifestyleState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;
  UserLifestyleController(this._matrimonyRepository, this._uid, this._ref)
    : super(LifestyleState.initial);

  Future<void> saveLifestyle({
    required String maritalStatus,
    required bool smoking,
    required bool drinking,
    required String foodHabit,
    required String hobbies,
  }) async {
    final lifestyleProfile = LifestyleProfile(
      diet: foodHabit,
      smoke: smoking.toString(),
      drink: drinking.toString(),
      hobbies: hobbies,
      interests: '',
      music: '',
      movies: '',
      sports: '',
      fitness: '',
    );

    try {
      // await _matrimonyRepository.updateLifestyleProfile(_uid, lifestyleProfile);

      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveLifestyle(lifestyleProfile);

      state = state.copyWith(lifestyle: lifestyleProfile, isLoading: false);

      debugPrint('✅ Lifestyle Saved Successfully');
      debugPrint(lifestyleProfile.toString());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userLifestyleControllerProvider =
    StateNotifierProvider.autoDispose<UserLifestyleController, LifestyleState>((
      ref,
    ) {
      final matrimonyRepo = ref.watch(matrimonyRepositoryProvider);
      final uid = ref.watch(authStateProvider).value?.uid;
      if (uid == null) throw Exception('User not authenticated');
      return UserLifestyleController(matrimonyRepo, uid, ref);
    });
