import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/global_providers.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/identity_state.dart';
import 'metrimony_profile_controller.dart';

class UserIdentityController extends StateNotifier<IdentityState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserIdentityController(this._matrimonyRepository, this._uid, this._ref)
    : super(IdentityState.initial);

  Future<void> updateIdentity({
    required BilingualValue gender,
    required DateTime dob,
    required int age,
    required String aadhar,
    required BilingualValue aboutMe,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final identityProfile = IdentityProfile(
      profileId: _uid,
      gender: gender,
      dob: dob,
      age: age,
      aadhar: aadhar,
      aboutMe: aboutMe,
    );

    try {
      await _ref
          .read(matrimonyRepositoryProvider)
          .updateIdentityProfile(_uid, identityProfile);

      state = state.copyWith(identity: identityProfile, isLoading: false);

      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveIdentity(identityProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveIdentity({
    required BilingualValue gender,
    required DateTime dob,
    required int age,
    required String aadhar,
    required BilingualValue aboutMe,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final identityProfile = IdentityProfile(
      profileId: _uid,
      aboutMe: aboutMe,
      gender: gender,
      dob: dob,
      age: age,
      aadhar: aadhar,
    );

    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'gender': gender.toMap(),
      });

      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveIdentity(identityProfile);

      state = state.copyWith(identity: identityProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final identityControllerProvider =
    StateNotifierProvider<UserIdentityController, IdentityState>((ref) {
      final repo = ref.read(matrimonyRepositoryProvider);
      final uid = ref.watch(targetUserIdProvider);

      return UserIdentityController(repo, uid ?? '', ref);
    });
