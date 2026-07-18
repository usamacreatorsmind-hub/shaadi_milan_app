import '../../../../translitration/models/bilingual_value.dart';

class CulturalProfile {
  final BilingualValue religion;
  final BilingualValue caste;
  final BilingualValue subCaste;
  final List<BilingualValue> languages;

  CulturalProfile({
    required this.religion,
    required this.caste,
    required this.subCaste,
    required this.languages,
  });

  Map<String, dynamic> toMap() {
    return {
      'religion': religion.toMap(),
      'caste': caste.toMap(),
      'subCaste': subCaste.toMap(),
      'languages': languages.map((l) => l.toMap()).toList(),
    };
  }

  factory CulturalProfile.fromMap(Map<String, dynamic> map) {
    BilingualValue parseBilingual(dynamic val) {
      if (val is Map) {
        return BilingualValue.fromMap(Map<String, dynamic>.from(val));
      }
      return BilingualValue(en: val?.toString() ?? '', hi: '');
    }

    return CulturalProfile(
      religion: parseBilingual(map['religion']),
      caste: parseBilingual(map['caste']),
      subCaste: parseBilingual(map['subCaste']),
      languages: (map['languages'] as List? ?? [])
          .map((l) => parseBilingual(l))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'CulturalProfile(religion: $religion, caste: $caste, subCaste: $subCaste, languages: $languages)';
  }

  CulturalProfile copyWith({
    BilingualValue? religion,
    BilingualValue? caste,
    BilingualValue? subCaste,
    List<BilingualValue>? languages,
  }) {
    return CulturalProfile(
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      subCaste: subCaste ?? this.subCaste,
      languages: languages ?? this.languages,
    );
  }

  factory CulturalProfile.empty() {
    return CulturalProfile(
      religion: BilingualValue.empty(),
      caste: BilingualValue.empty(),
      subCaste: BilingualValue.empty(),
      languages: [],
    );
  }
}

class CulturalState {
  final CulturalProfile? cultural;
  final bool isLoading;
  final String? error;

  CulturalState({this.cultural, this.isLoading = false, this.error});

  CulturalState copyWith({
    CulturalProfile? cultural,
    bool? isLoading,
    String? error,
  }) {
    return CulturalState(
      cultural: cultural ?? this.cultural,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static final initial = CulturalState(
    cultural: null,
    isLoading: false,
    error: null,
  );
}
