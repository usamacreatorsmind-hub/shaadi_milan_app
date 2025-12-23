class EducationProfile {
  final String highestQualification;
  final String college;
  final String degree;
  final String occupation;
  final int passingYear;

  EducationProfile({
    required this.highestQualification,
    required this.college,
    required this.degree,
    required this.occupation,
    required this.passingYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'highestQualification': highestQualification,
      'college': college,
      'degree': degree,
      'occupation': occupation,
      'passingYear': passingYear,
    };
  }

  factory EducationProfile.fromMap(Map<String, dynamic> map) {
    return EducationProfile(
      highestQualification: map['highestQualification'] as String,
      college: map['college'] as String,
      degree: map['degree'] as String,
      occupation: map['occupation'] as String,
      passingYear: map['passingYear'] as int,
    );
  }

  @override
  String toString() {
    return 'EducationProfile(highestQualification: $highestQualification, college: $college, degree: $degree, occupation: $occupation,)';
  }

  EducationProfile copyWith({
    String? highestQualification,
    String? college,
    String? degree,
    String? occupation,
    int? annualIncome,
    int? passingYear,
  }) {
    return EducationProfile(
      highestQualification: highestQualification ?? this.highestQualification,
      college: college ?? this.college,
      degree: degree ?? this.degree,
      occupation: occupation ?? this.occupation,
      passingYear: passingYear ?? this.passingYear,
    );
  }

  factory EducationProfile.empty() {
    return EducationProfile(
      highestQualification: '',
      college: '',
      degree: '',
      occupation: '',
      passingYear: 0,
    );
  }
}

class EducationState {
  final EducationProfile? education;
  final bool isLoading;
  final String? error;

  const EducationState({this.education, this.isLoading = false, this.error});

  EducationState copyWith({
    EducationProfile? education,
    bool? isLoading,
    String? error,
  }) {
    return EducationState(
      education: education ?? this.education,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = EducationState(
    education: null,
    isLoading: false,
    error: null,
  );
}
