import '../../../../translitration/models/bilingual_value.dart';

class CulturalProfile {
  final BilingualValue religion;
  final BilingualValue caste;
  final List<BilingualValue> languages;
  final BilingualValue? manglikStatus;

  CulturalProfile({required this.religion, required this.caste, required this.languages, this.manglikStatus});

  Map<String, dynamic> toMap() {
    return {
      'religion': religion.toMap(),
      'caste': caste.toMap(),
      'languages': languages.map((l) => l.toMap()).toList(),
      'manglikStatus': manglikStatus?.toMap(),
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
      languages: (map['languages'] as List? ?? []).map((l) => parseBilingual(l)).toList(),
      manglikStatus: map['manglikStatus'] != null ? parseBilingual(map['manglikStatus']) : null,
    );
  }

  @override
  String toString() {
    return 'CulturalProfile(religion: $religion, caste: $caste, languages: $languages, manglikStatus: $manglikStatus)';
  }

  CulturalProfile copyWith({BilingualValue? religion, BilingualValue? caste, List<BilingualValue>? languages, BilingualValue? manglikStatus}) {
    return CulturalProfile(
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      languages: languages ?? this.languages,
      manglikStatus: manglikStatus ?? this.manglikStatus,
    );
  }

  factory CulturalProfile.empty() {
    return CulturalProfile(religion: BilingualValue.empty(), caste: BilingualValue.empty(), languages: [], manglikStatus: null);
  }
}

class CulturalState {
  final CulturalProfile? cultural;
  final bool isLoading;
  final String? error;

  CulturalState({this.cultural, this.isLoading = false, this.error});

  CulturalState copyWith({CulturalProfile? cultural, bool? isLoading, String? error}) {
    return CulturalState(cultural: cultural ?? this.cultural, isLoading: isLoading ?? this.isLoading, error: error);
  }

  static final initial = CulturalState(cultural: null, isLoading: false, error: null);
}
