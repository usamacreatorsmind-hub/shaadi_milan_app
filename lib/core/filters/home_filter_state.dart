/// =======================
/// FILTER STATE
/// =======================
class HomeFilterState {
  final String state;
  final String city;
  final String religion;
  final String caste;

  const HomeFilterState({
    required this.state,
    required this.city,
    required this.religion,
    required this.caste,
  });

  HomeFilterState copyWith({
    String? state,
    String? city,
    String? religion,
    String? caste,
  }) {
    return HomeFilterState(
      state: state ?? this.state,
      city: city ?? this.city,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
    );
  }
}