import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
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

  // update identity proifile with metrimony repository

  Future<void> updateIdentity({
    required String gender,
    required DateTime dob,
    required int age,
    required String aadhar,
    required String aboutMe,
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
      _ref
          .read(matrimonyRepositoryProvider)
          .updateIdentityProfile(_uid, identityProfile);

      state = state.copyWith(identity: identityProfile, isLoading: false);

      debugPrint('✅ Identity Updated Successfully');
      debugPrint(identityProfile.toString());
      // update ui also
      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveIdentity(identityProfile);
    } catch (e) {
      debugPrint('❌ Identity Update Failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveIdentity({
    required String gender,
    required DateTime dob,
    required int age,
    required String aadhar,
    required String aboutMe,
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
      // Update gender in users collection
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'gender': gender,
      });

      // Update Matrimony Profile
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
      final repo = ref.read(matrimonyRepositoryProvider);
      final authState = ref.read(authStateProvider);

      final uid = authState.value?.fold(
        (agent) => agent.uid,
        (user) => user.uid,
      );
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      return UserIdentityController(repo, uid, ref);
    });
