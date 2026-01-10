import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/physical_state.dart';
import 'metrimony_profile_controller.dart';

class UserPhysicalController extends StateNotifier<PhysicalState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserPhysicalController(this._matrimonyRepository, this._uid, this._ref)
    : super(PhysicalState.initial);

  Future<void> savePhysicals({
    required double height,
    required double weight,
    required String bodyType,
    required String complexion,
    required bool physicallyChallenged,
    String? disabilityDetails,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final physicalProfile = PhysicalProfile(
      height: height,
      weight: weight,
      bodyType: bodyType,
      complexion: complexion,
      physicallyChallenged: physicallyChallenged,
      disabilityDetails: disabilityDetails,
    );

    try {
      _ref
          .read(metrimonyControllerProvider.notifier)
          .savePhysical(physicalProfile);
      state = state.copyWith(physical: physicalProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePhysicals({
    required double height,
    required double weight,
    required String bodyType,
    required String complexion,
    required bool physicallyChallenged,
    String? disabilityDetails,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final physicalProfile = PhysicalProfile(
      height: height,
      weight: weight,
      bodyType: bodyType,
      complexion: complexion,
      physicallyChallenged: physicallyChallenged,
      disabilityDetails: disabilityDetails,
    );

    try {
      _ref
          .read(matrimonyRepositoryProvider)
          .updatePhysicalProfile(_uid, physicalProfile);
      state = state.copyWith(physical: physicalProfile, isLoading: false);
      _ref
          .read(metrimonyControllerProvider.notifier)
          .savePhysical(physicalProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userPhysicalControllerProvider =
    StateNotifierProvider.autoDispose<UserPhysicalController, PhysicalState>((
      ref,
    ) {
      final matrimonyRepo = ref.read(matrimonyRepositoryProvider);
      final authState = ref.read(authStateProvider);
      final uid = authState.value?.fold((agent) => null, (user) => user.uid);
      if (uid == null) throw Exception('User not authenticated');
      return UserPhysicalController(matrimonyRepo, uid, ref);
    });
