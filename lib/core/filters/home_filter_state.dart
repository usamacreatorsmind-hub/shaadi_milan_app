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
  final bool daily;
  final bool myMatches;
  final double minAge;
  final double maxAge;
  final String searchQuery;

  const HomeFilterState({
    this.state = '',
    this.city = '',
    this.religion = '',
    this.caste = '',
    this.gender = '',
    this.justJoined = false,
    this.fromMyCity = false,
    this.daily = false,
    this.myMatches = false,
    this.minAge = 18,
    this.maxAge = 60,
    this.searchQuery = '',
  });

  HomeFilterState copyWith({
    String? state,
    String? city,
    String? religion,
    String? caste,
    String? gender,
    bool? justJoined,
    bool? fromMyCity,
    bool? daily,
    bool? myMatches,
    double? minAge,
    double? maxAge,
    String? searchQuery,
  }) {
    return HomeFilterState(
      state: state ?? this.state,
      city: city ?? this.city,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      gender: gender ?? this.gender,
      justJoined: justJoined ?? this.justJoined,
      fromMyCity: fromMyCity ?? this.fromMyCity,
      daily: daily ?? this.daily,
      myMatches: myMatches ?? this.myMatches,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
