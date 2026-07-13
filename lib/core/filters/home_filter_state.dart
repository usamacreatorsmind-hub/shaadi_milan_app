/// =======================
/// FILTER STATE
/// =======================
class HomeFilterState {
  final String state;
  final String city;
  final String religion;
  final String caste;
  final String gender;

  const HomeFilterState({
    this.state = '',
    this.city = '',
    this.religion = '',
    this.caste = '',
    this.gender = '',
  });

  HomeFilterState copyWith({
    String? state,
    String? city,
    String? religion,
    String? caste,
    String? gender,
  }) {
    return HomeFilterState(
      state: state ?? this.state,
      city: city ?? this.city,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      gender: gender ?? this.gender,
    );
  }
}
