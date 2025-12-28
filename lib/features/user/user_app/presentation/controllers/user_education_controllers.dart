import 'package:flutter_riverpod/legacy.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/education_state.dart';
import 'metrimony_profile_controller.dart';
import 'package:flutter/material.dart';

import '../../domain/states/cultural_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserEducationController extends StateNotifier<EducationState> {
  final String _uid;
  final Ref _ref;

  UserEducationController(this._uid, this._ref) : super(EducationState.initial);

  Future<void> saveEducation({required Education education}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final educationProfile = EducationProfile(education: education);
      state = state.copyWith(isLoading: false, education: educationProfile);
      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveEducation(educationProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint(e.toString());
    }
  }
}

final userEducationControllerProvider =
    StateNotifierProvider.autoDispose<UserEducationController, EducationState>((
      ref,
    ) {
      final uid = ref.watch(authStateProvider).value?.uid;
      if (uid == null) throw Exception('User not authenticated');
      return UserEducationController(uid, ref);
    });
