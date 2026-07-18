import '../../../../translitration/models/bilingual_value.dart';

class FamilyProfile {
  final BilingualValue fatherName;
  final BilingualValue motherName;
  final int numberOfBrothers;
  final int numberOfSisters;
  final BilingualValue familyType;
  final BilingualValue familyStatus;

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
      'fatherName': fatherName.toMap(),
      'motherName': motherName.toMap(),
      'numberOfBrothers': numberOfBrothers,
      'numberOfSisters': numberOfSisters,
      'familyType': familyType.toMap(),
      'familyStatus': familyStatus.toMap(),
    };
  }

  factory FamilyProfile.fromMap(Map<String, dynamic> map) {
    BilingualValue parseBilingual(dynamic val) {
      if (val is Map) {
        return BilingualValue.fromMap(Map<String, dynamic>.from(val));
      }
      return BilingualValue(en: val?.toString() ?? '', hi: '');
    }

    return FamilyProfile(
      fatherName: parseBilingual(map['fatherName']),
      motherName: parseBilingual(map['motherName']),
      numberOfBrothers:
          int.tryParse(map['numberOfBrothers']?.toString() ?? '') ?? 0,
      numberOfSisters:
          int.tryParse(map['numberOfSisters']?.toString() ?? '') ?? 0,
      familyType: parseBilingual(map['familyType']),
      familyStatus: parseBilingual(map['familyStatus']),
    );
  }

  @override
  String toString() {
    return 'FamilyProfile(fatherName: $fatherName, motherName: $motherName, numberOfBrothers: $numberOfBrothers, numberOfSisters: $numberOfSisters, familyType: $familyType, familyStatus: $familyStatus)';
  }

  FamilyProfile copyWith({
    BilingualValue? fatherName,
    BilingualValue? motherName,
    int? numberOfBrothers,
    int? numberOfSisters,
    BilingualValue? familyType,
    BilingualValue? familyStatus,
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
      fatherName: BilingualValue.empty(),
      motherName: BilingualValue.empty(),

      numberOfBrothers: 0,
      numberOfSisters: 0,

      familyType: BilingualValue.empty(),
      familyStatus: BilingualValue.empty(),
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
