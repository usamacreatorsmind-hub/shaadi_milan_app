import 'package:arvika_marriage_bureau/core/filters/home_filter_state.dart';
import 'package:flutter_riverpod/legacy.dart';

/// =======================
/// FILTER PROVIDER
/// =======================
final matchFilterProvider =
    StateNotifierProvider<MatchFilterController, HomeFilterState>(
      (ref) => MatchFilterController(),
    );

class MatchFilterController extends StateNotifier<HomeFilterState> {
  MatchFilterController()
    : super(
        const HomeFilterState(state: '', city: '', religion: '', caste: ''),
      );

  void updateState(String value) {
    // reset city when state changes
    state = state.copyWith(state: value, city: '');
  }

  void reset() {
    state = const HomeFilterState(state: '', city: '', religion: '', caste: '');
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
}

/// =======================
/// FILTER STATE
/// =======================
class MatchFilterState {
  final String state;
  final String city;
  final String religion;
  final String caste;

  const MatchFilterState({
    required this.state,
    required this.city,
    required this.religion,
    required this.caste,
  });

  MatchFilterState copyWith({
    String? state,
    String? city,
    String? religion,
    String? caste,
  }) {
    return MatchFilterState(
      state: state ?? this.state,
      city: city ?? this.city,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
    );
  }
}
