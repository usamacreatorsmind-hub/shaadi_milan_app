import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/cultural_state.dart';
import 'metrimony_profile_controller.dart';

class UserCulturalController extends StateNotifier<CulturalState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserCulturalController(this._matrimonyRepository, this._uid, this._ref)
    : super(CulturalState.initial);

  Future<void> saveCultural({
    required String religion,
    required String caste,
    required String subCaste,
    // required String motherTongue,
    required List<String> languages,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final culturalProfile = CulturalProfile(
      religion: religion,
      caste: caste,
      subCaste: subCaste,
      // motherTongue: motherTongue,
      languages: languages,
    );

    try {
      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveCultural(culturalProfile);

      state = state.copyWith(cultural: culturalProfile, isLoading: false);

      debugPrint('✅ Cultural Saved Successfully');
      debugPrint(culturalProfile.toString());
    } catch (e) {
      debugPrint('❌ Cultural Save Failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userCulturalControllerProvider =
    StateNotifierProvider.autoDispose<UserCulturalController, CulturalState>((
      ref,
    ) {
      final matrimonyRepo = ref.watch(matrimonyRepositoryProvider);
      final uid = ref.watch(authStateProvider).value?.uid;
      if (uid == null) throw Exception('User not authenticated');
      return UserCulturalController(matrimonyRepo, uid, ref);
    });
