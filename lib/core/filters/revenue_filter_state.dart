/// =======================
/// FILTER STATE
/// =======================
class RevenueFilterState {
  final String state;
  final String city;
  final String religion;
  final String caste;
  final String gender;
  final DateTime startDate;
  final DateTime endDate;

  const RevenueFilterState({
    required this.state,
    required this.city,
    required this.religion,
    required this.caste,
    required this.gender,

    required this.startDate,
    required this.endDate,
  });

  RevenueFilterState copyWith({
    String? state,
    String? city,
    String? religion,
    String? caste,
    String? gender,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return RevenueFilterState(
      gender: gender ?? this.gender,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      state: state ?? this.state,
      city: city ?? this.city,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
    );
  }
}
