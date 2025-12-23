class CulturalProfile {
  final String religion;
  final String caste;
  final String subCaste;
  final String gothra;
  final String motherTongue;
  final List<String> languages;

  CulturalProfile({
    required this.religion,
    required this.caste,
    required this.subCaste,
    required this.gothra,
    required this.motherTongue,
    required this.languages,
  });

  Map<String, dynamic> toMap() {
    return {
      'religion': religion,
      'caste': caste,
      'subCaste': subCaste,
      'gothra': gothra,
      'motherTongue': motherTongue,
      'languages': languages,
    };
  }

  factory CulturalProfile.fromMap(Map<String, dynamic> map) {
    return CulturalProfile(
      religion: map['religion'] as String,
      caste: map['caste'] as String,
      subCaste: map['subCaste'] as String,
      gothra: map['gothra'] as String,
      motherTongue: map['motherTongue'] as String,
      languages: List<String>.from(map['languages'] as List),
    );
  }

  @override
  String toString() {
    return 'CulturalProfile(religion: $religion, caste: $caste, subCaste: $subCaste, gothra: $gothra, motherTongue: $motherTongue, languages: $languages)';
  }

  CulturalProfile copyWith({
    String? religion,
    String? caste,
    String? subCaste,
    String? gothra,
    String? motherTongue,
    List<String>? languages,
  }) {
    return CulturalProfile(
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      subCaste: subCaste ?? this.subCaste,
      gothra: gothra ?? this.gothra,
      motherTongue: motherTongue ?? this.motherTongue,
      languages: languages ?? this.languages,
    );
  }

  factory CulturalProfile.empty() {
    return CulturalProfile(
      religion: '',
      caste: '',
      subCaste: '',
      gothra: '',
      motherTongue: '',
      languages: [],
    );
  }
}

class CulturalState {
  CulturalProfile? cultural;
  bool isLoading;
  String? error;

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
