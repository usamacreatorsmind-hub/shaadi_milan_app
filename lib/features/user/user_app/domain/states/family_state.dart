class FamilyProfile {
  final String fatherName;
  final String motherName;
  final int numberOfBrothers;
  final int numberOfSisters;
  final String familyType;
  final String familyStatus;

  FamilyProfile({
    required this.fatherName,
    required this.motherName,
    required this.numberOfBrothers,
    required this.numberOfSisters,
    required this.familyType,
    required this.familyStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'fatherName': fatherName,
      'motherName': motherName,
      'numberOfBrothers': numberOfBrothers,
      'numberOfSisters': numberOfSisters,

      'familyType': familyType,
      'familyStatus': familyStatus,
    };
  }

  factory FamilyProfile.fromMap(Map<String, dynamic> map) {
    return FamilyProfile(
      fatherName: map['fatherName'] as String? ?? '',
      motherName: map['motherName'] as String? ?? '',

      numberOfBrothers: map['numberOfBrothers'] as int? ?? 0,
      numberOfSisters: map['numberOfSisters'] as int? ?? 0,

      familyType: map['familyType'] as String? ?? '',
      familyStatus: map['familyStatus'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'FamilyProfile(fatherName: $fatherName, motherName: $motherName, numberOfBrothers: $numberOfBrothers, numberOfSisters: $numberOfSisters, familyType: $familyType, familyStatus: $familyStatus)';
  }

  FamilyProfile copyWith({
    String? fatherName,
    String? motherName,
    int? numberOfBrothers,
    int? numberOfSisters,
    String? familyType,
    String? familyStatus,
  }) {
    return FamilyProfile(
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,

      numberOfBrothers: numberOfBrothers ?? this.numberOfBrothers,
      numberOfSisters: numberOfSisters ?? this.numberOfSisters,

      familyType: familyType ?? this.familyType,
      familyStatus: familyStatus ?? this.familyStatus,
    );
  }

  factory FamilyProfile.empty() {
    return FamilyProfile(
      fatherName: '',
      motherName: '',

      numberOfBrothers: 0,
      numberOfSisters: 0,

      familyType: '',
      familyStatus: '',
    );
  }
}

class FamilyState {
  final FamilyProfile? family;
  final bool isLoading;
  final String? error;

  const FamilyState({this.family, this.isLoading = false, this.error});

  FamilyState copyWith({
    FamilyProfile? family,
    bool? isLoading,
    String? error,
  }) {
    return FamilyState(
      family: family ?? this.family,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = FamilyState(
    family: null,
    isLoading: false,
    error: null,
  );
}
