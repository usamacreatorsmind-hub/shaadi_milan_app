import 'package:flutter_riverpod/legacy.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/identity_state.dart';
import 'metrimony_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserIdentityController extends StateNotifier<IdentityState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserIdentityController(this._matrimonyRepository, this._uid, this._ref)
    : super(IdentityState.initial);

  Future<void> saveIdentity({
    required String gender,
    required DateTime dob,
    required int age,
    required String aadhar,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final identityProfile = IdentityProfile(
      profileId: _uid,

      gender: gender,
      dob: dob,
      age: age,
      aadhar: aadhar,
    );

    try {
      // await _matrimonyRepository.updateIdentityProfile(_uid, identityProfile);

      // 🔹 Update Matrimony Profile

      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveIdentity(identityProfile);

      state = state.copyWith(identity: identityProfile, isLoading: false);

      debugPrint('✅ Identity Saved Successfully');
      debugPrint(identityProfile.toString());
    } catch (e) {
      debugPrint('❌ Identity Save Failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final identityControllerProvider =
    StateNotifierProvider<UserIdentityController, IdentityState>((ref) {
      final repo = ref.watch(matrimonyRepositoryProvider);
      final authState = ref.watch(authStateProvider);

      final uid = authState.value?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      return UserIdentityController(repo, uid, ref);
    });
