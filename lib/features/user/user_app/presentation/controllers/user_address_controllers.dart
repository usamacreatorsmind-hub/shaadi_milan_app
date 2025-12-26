import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../user_auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/address_state.dart';
import 'metrimony_profile_controller.dart';

class UserAddressController extends StateNotifier<AddressState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserAddressController(this._matrimonyRepository, this._uid, this._ref)
    : super(AddressState.initial);

  Future<void> saveAddress({
    required String at,
    required String post,
    required String policeStation,

    required String district,
    required String stateName,
    required String pin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final addressProfile = AddressProfile(
      policeStation: policeStation,

      addressLine1: at,
      post: post,
      city: district,
      state: stateName,
      pincode: pin,
    );

    try {
      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveAddress(addressProfile);

      state = state.copyWith(address: addressProfile, isLoading: false);
      debugPrint('✅ Address Saved Successfully');
      debugPrint(addressProfile.toString());
    } catch (e) {
      debugPrint('❌ Address Save Failed: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final addressControllerProvider =
    StateNotifierProvider<UserAddressController, AddressState>((ref) {
      final repo = ref.watch(matrimonyRepositoryProvider);
      final authState = ref.watch(authStateProvider);

      final uid = authState.value?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      return UserAddressController(repo, uid, ref);
    });
