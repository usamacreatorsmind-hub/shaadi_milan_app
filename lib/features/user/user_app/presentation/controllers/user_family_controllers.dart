import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import 'metrimony_profile_controller.dart';
import '../../domain/states/family_state.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/education_state.dart';
import 'metrimony_profile_controller.dart';
import 'package:flutter/material.dart';

import '../../domain/states/cultural_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class UserFamilyController extends StateNotifier<FamilyState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserFamilyController(this._matrimonyRepository, this._uid, this._ref)
    : super(FamilyState.initial);

  Future<void> saveFamily({
    required String fatherName,
    required String motherName,
    required int brothers,
    required int sisters,
    required String familyType,
    required String familyStatus,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final familyProfile = FamilyProfile(
      fatherName: fatherName,
      motherName: motherName,

      numberOfBrothers: brothers,
      numberOfSisters: sisters,

      familyType: familyType,
      familyStatus: familyStatus,
    );

    try {
      // await _matrimonyRepository.updateFamilyProfile(_uid, familyProfile);

      _ref.read(metrimonyControllerProvider.notifier).saveFamily(familyProfile);

      state = state.copyWith(family: familyProfile, isLoading: false);

      debugPrint('✅ Identity Saved Successfully');
      debugPrint(familyProfile.toString());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userFamilyControllerProvider =
    StateNotifierProvider.autoDispose<UserFamilyController, FamilyState>((ref) {
      final matrimonyRepo = ref.watch(matrimonyRepositoryProvider);
      final uid = ref.watch(authStateProvider).value?.uid;
      if (uid == null) throw Exception('User not authenticated');
      return UserFamilyController(matrimonyRepo, uid, ref);
    });
