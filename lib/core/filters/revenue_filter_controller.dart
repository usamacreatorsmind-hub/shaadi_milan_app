import 'home_filter_state.dart';
import 'revenue_filter_state.dart';
import 'package:flutter_riverpod/legacy.dart';

/// =======================
/// FILTER PROVIDER
/// =======================
final revenueFilterProvider =
    StateNotifierProvider<RevenueFilterController, RevenueFilterState>(
      (ref) => RevenueFilterController(),
    );

class RevenueFilterController extends StateNotifier<RevenueFilterState> {
  RevenueFilterController()
    : super(
        RevenueFilterState(
          state: '',
          city: '',
          religion: '',
          caste: '',
          gender: '',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
      );

  void updateState(String value) {
    // reset city when state changes
    state = state.copyWith(state: value, city: '');
  }

  void reset() {
    state = RevenueFilterState(
      state: '',
      city: '',
      religion: '',
      caste: '',
      gender: '',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
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

  void updateStartDate(DateTime value) {
    state = state.copyWith(startDate: value);
  }

  void updateEndDate(DateTime value) {
    state = state.copyWith(endDate: value);
  }

  void updateGender(String? value) {
    state = state.copyWith(gender: value);
  }
}
