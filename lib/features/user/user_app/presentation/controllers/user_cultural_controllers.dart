import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/global_providers.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/cultural_state.dart';
import 'metrimony_profile_controller.dart';

class UserCulturalController extends StateNotifier<CulturalState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserCulturalController(this._matrimonyRepository, this._uid, this._ref) : super(CulturalState.initial);

  Future<void> saveCultural({
    required BilingualValue religion,
    required BilingualValue caste,
    required List<BilingualValue> languages,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final culturalProfile = CulturalProfile(religion: religion, caste: caste, languages: languages);

    try {
      _ref.read(metrimonyControllerProvider.notifier).saveCultural(culturalProfile);

      state = state.copyWith(cultural: culturalProfile, isLoading: false);

      debugPrint('✅ Cultural Saved Successfully');
      debugPrint(culturalProfile.toString());
    } catch (e) {
      debugPrint('❌ Cultural Save Failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateCultural({required BilingualValue religion, required BilingualValue caste, required List<BilingualValue> languages}) {
    state = state.copyWith(isLoading: true, error: null);
    final culturalProfile = CulturalProfile(religion: religion, caste: caste, languages: languages);

    try {
      _ref.read(matrimonyRepositoryProvider).updateCulturalProfile(_uid, culturalProfile);

      state = state.copyWith(cultural: culturalProfile, isLoading: false);
      debugPrint('✅ Cultural Updated Successfully');
      debugPrint(culturalProfile.toString());
      _ref.read(metrimonyControllerProvider.notifier).saveCultural(culturalProfile);
    } catch (e) {
      debugPrint('❌ Cultural Update Failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final cultureControllerProvider = StateNotifierProvider.autoDispose<UserCulturalController, CulturalState>((ref) {
  final matrimonyRepo = ref.read(matrimonyRepositoryProvider);
  final uid = ref.watch(targetUserIdProvider);
  return UserCulturalController(matrimonyRepo, uid ?? '', ref);
});
