
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/global_providers.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/address_state.dart';
import 'metrimony_profile_controller.dart';

class UserAddressController extends StateNotifier<AddressState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserAddressController(this._matrimonyRepository, this._uid, this._ref) : super(AddressState.initial);

  Future<void> saveAddress({
    required BilingualValue at,
    required BilingualValue post,
    required BilingualValue policeStation,
    required BilingualValue district,
    required BilingualValue stateName,
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
      _ref.read(metrimonyControllerProvider.notifier).saveAddress(addressProfile);

      state = state.copyWith(address: addressProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateAddress({
    required BilingualValue at,
    required BilingualValue post,
    required BilingualValue policeStation,
    required BilingualValue district,
    required BilingualValue stateName,
    required String pin,
  }) {
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
      _ref.read(matrimonyRepositoryProvider).updateAddressProfile(_uid, addressProfile);

      state = state.copyWith(address: addressProfile, isLoading: false);
      _ref.read(metrimonyControllerProvider.notifier).saveAddress(addressProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final addressControllerProvider = StateNotifierProvider<UserAddressController, AddressState>((ref) {
  final repo = ref.read(matrimonyRepositoryProvider);
  final uid = ref.watch(targetUserIdProvider);

  return UserAddressController(repo, uid ?? '', ref);
});
