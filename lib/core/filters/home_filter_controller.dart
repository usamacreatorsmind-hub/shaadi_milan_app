
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_filter_state.dart';

/// =======================
/// FILTER PROVIDER
/// =======================
final homeFilterProvider =
    StateNotifierProvider<HomeFilterController, HomeFilterState>(
      (ref) => HomeFilterController(),
    );

class HomeFilterController extends StateNotifier<HomeFilterState> {
  HomeFilterController() : super(   HomeFilterState());

  void updateState(String value) {
    // reset city when state changes
    state = state.copyWith(state: value, city: '');
  }

  void reset() {
    state = const HomeFilterState();
  }

  void updateCity(String value) {
    state = state.copyWith(city: value);
  }

  void updateReligion(String value) {
    // reset caste when religion changes
    state = state.copyWith(religion: value, caste: '');
  }

  void updateCaste(String value) {
    state = state.copyWith(caste: value);
  }

  void updateGender(String value) {
    state = state.copyWith(gender: value);
  }
}
