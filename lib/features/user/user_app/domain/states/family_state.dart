class FamilyProfile {
  final String fatherName;
  final String motherName;
  final String fatherOccupation;
  final String motherOccupation;
  final int numberOfBrothers;
  final int numberOfSisters;
  final int brothersMarried;
  final int sistersMarried;
  final String familyType;
  final String familyStatus;
  final String familyValues;

  FamilyProfile({
    required this.fatherName,
    required this.motherName,
    required this.fatherOccupation,
    required this.motherOccupation,
    required this.numberOfBrothers,
    required this.numberOfSisters,
    required this.brothersMarried,
    required this.sistersMarried,
    required this.familyType,
    required this.familyStatus,
    required this.familyValues,
  });

  Map<String, dynamic> toMap() {
    return {
      'fatherName': fatherName,
      'motherName': motherName,
      'fatherOccupation': fatherOccupation,
      'motherOccupation': motherOccupation,
      'numberOfBrothers': numberOfBrothers,
      'numberOfSisters': numberOfSisters,
      'brothersMarried': brothersMarried,
      'sistersMarried': sistersMarried,
      'familyType': familyType,
      'familyStatus': familyStatus,
      'familyValues': familyValues,
    };
  }

  factory FamilyProfile.fromMap(Map<String, dynamic> map) {
    return FamilyProfile(
      fatherName: map['fatherName'] as String,
      motherName: map['motherName'] as String,
      fatherOccupation: map['fatherOccupation'] as String,
      motherOccupation: map['motherOccupation'] as String,
      numberOfBrothers: map['numberOfBrothers'] as int,
      numberOfSisters: map['numberOfSisters'] as int,
      brothersMarried: map['brothersMarried'] as int,
      sistersMarried: map['sistersMarried'] as int,
      familyType: map['familyType'] as String,
      familyStatus: map['familyStatus'] as String,
      familyValues: map['familyValues'] as String,
    );
  }

  @override
  String toString() {
    return 'FamilyProfile(fatherName: $fatherName, motherName: $motherName, fatherOccupation: $fatherOccupation, motherOccupation: $motherOccupation, numberOfBrothers: $numberOfBrothers, numberOfSisters: $numberOfSisters, brothersMarried: $brothersMarried, sistersMarried: $sistersMarried, familyType: $familyType, familyStatus: $familyStatus, familyValues: $familyValues)';
  }

  FamilyProfile copyWith({
    String? fatherName,
    String? motherName,
    String? fatherOccupation,
    String? motherOccupation,
    int? numberOfBrothers,
    int? numberOfSisters,
    int? brothersMarried,
    int? sistersMarried,
    String? familyType,
    String? familyStatus,
    String? familyValues,
  }) {
    return FamilyProfile(
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      numberOfBrothers: numberOfBrothers ?? this.numberOfBrothers,
      numberOfSisters: numberOfSisters ?? this.numberOfSisters,
      brothersMarried: brothersMarried ?? this.brothersMarried,
      sistersMarried: sistersMarried ?? this.sistersMarried,
      familyType: familyType ?? this.familyType,
      familyStatus: familyStatus ?? this.familyStatus,
      familyValues: familyValues ?? this.familyValues,
    );
  }

  factory FamilyProfile.empty() {
    return FamilyProfile(
      fatherName: '',
      motherName: '',
      fatherOccupation: '',
      motherOccupation: '',
      numberOfBrothers: 0,
      numberOfSisters: 0,
      brothersMarried: 0,
      sistersMarried: 0,
      familyType: '',
      familyStatus: '',
      familyValues: '',
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
