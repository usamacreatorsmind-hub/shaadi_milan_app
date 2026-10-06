import '../../../../translitration/models/bilingual_value.dart';

class FamilyProfile {
  final BilingualValue fatherName;
  final BilingualValue motherName;
  final BilingualValue? fatherOccupation;
  final BilingualValue? motherOccupation;
  final int numberOfBrothers;
  final int numberOfSisters;
  final BilingualValue familyType;
  final BilingualValue familyStatus;
  final BilingualValue? familyIncome;

  FamilyProfile({
    required this.fatherName,
    required this.motherName,
    this.fatherOccupation,
    this.motherOccupation,
    required this.numberOfBrothers,
    required this.numberOfSisters,
    required this.familyType,
    required this.familyStatus,
    this.familyIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'fatherName': fatherName.toMap(),
      'motherName': motherName.toMap(),
      'fatherOccupation': fatherOccupation?.toMap(),
      'motherOccupation': motherOccupation?.toMap(),
      'numberOfBrothers': numberOfBrothers,
      'numberOfSisters': numberOfSisters,
      'familyType': familyType.toMap(),
      'familyStatus': familyStatus.toMap(),
      'familyIncome': familyIncome?.toMap(),
    };
  }

  factory FamilyProfile.fromMap(Map<String, dynamic> map) {
    BilingualValue parseBilingual(dynamic val) {
      if (val is Map) {
        return BilingualValue.fromMap(Map<String, dynamic>.from(val));
      }
      return BilingualValue(en: val?.toString() ?? '', hi: '');
    }

    BilingualValue? parseOptionalBilingual(dynamic val) {
      if (val == null) return null;
      return parseBilingual(val);
    }

    return FamilyProfile(
      fatherName: parseBilingual(map['fatherName']),
      motherName: parseBilingual(map['motherName']),
      fatherOccupation: parseOptionalBilingual(map['fatherOccupation']),
      motherOccupation: parseOptionalBilingual(map['motherOccupation']),
      numberOfBrothers:
          int.tryParse(map['numberOfBrothers']?.toString() ?? '') ?? 0,
      numberOfSisters:
          int.tryParse(map['numberOfSisters']?.toString() ?? '') ?? 0,
      familyType: parseBilingual(map['familyType']),
      familyStatus: parseBilingual(map['familyStatus']),
      familyIncome: map['familyIncome'] != null ? parseBilingual(map['familyIncome']) : null,
    );
  }

  @override
  String toString() {
    return 'FamilyProfile(fatherName: $fatherName, motherName: $motherName, fatherOccupation: $fatherOccupation, motherOccupation: $motherOccupation, numberOfBrothers: $numberOfBrothers, numberOfSisters: $numberOfSisters, familyType: $familyType, familyStatus: $familyStatus, familyIncome: $familyIncome)';
  }

  FamilyProfile copyWith({
    BilingualValue? fatherName,
    BilingualValue? motherName,
    BilingualValue? fatherOccupation,
    BilingualValue? motherOccupation,
    int? numberOfBrothers,
    int? numberOfSisters,
    BilingualValue? familyType,
    BilingualValue? familyStatus,
    BilingualValue? familyIncome,
  }) {
    return FamilyProfile(
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      numberOfBrothers: numberOfBrothers ?? this.numberOfBrothers,
      numberOfSisters: numberOfSisters ?? this.numberOfSisters,
      familyType: familyType ?? this.familyType,
      familyStatus: familyStatus ?? this.familyStatus,
      familyIncome: familyIncome ?? this.familyIncome,
    );
  }

  factory FamilyProfile.empty() {
    return FamilyProfile(
      fatherName: BilingualValue.empty(),
      motherName: BilingualValue.empty(),
      fatherOccupation: null,
      motherOccupation: null,
      numberOfBrothers: 0,
      numberOfSisters: 0,
      familyType: BilingualValue.empty(),
      familyStatus: BilingualValue.empty(),
      familyIncome: null,
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
