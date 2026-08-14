/// =======================
/// FILTER STATE
/// =======================
class HomeFilterState {
  final String state;
  final String city;
  final String religion;
  final String caste;
  final String gender;
  final bool justJoined;
  final bool fromMyCity;
  final double minAge;
  final double maxAge;

  const HomeFilterState({
    this.state = '',
    this.city = '',
    this.religion = '',
    this.caste = '',
    this.gender = '',
    this.justJoined = false,
    this.fromMyCity = false,
    this.minAge = 18,
    this.maxAge = 60,
  });

  HomeFilterState copyWith({
    String? state,
    String? city,
    String? religion,
    String? caste,
    String? gender,
    bool? justJoined,
    bool? fromMyCity,
    double? minAge,
    double? maxAge,
  }) {
    return HomeFilterState(
      state: state ?? this.state,
      city: city ?? this.city,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      gender: gender ?? this.gender,
      justJoined: justJoined ?? this.justJoined,
      fromMyCity: fromMyCity ?? this.fromMyCity,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
    );
  }
}
