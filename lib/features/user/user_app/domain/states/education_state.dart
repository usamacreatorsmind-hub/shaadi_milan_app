class Education {
  final String college;
  final String degree;
  final int passingYear;
  final double percentage;

  Education({
    required this.college,
    required this.degree,
    required this.passingYear,
    required this.percentage,
  });
  Map<String, dynamic> toMap() {
    return {
      'college': college,
      'degree': degree,
      'percentage': percentage,
      'passingYear': passingYear,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      college: map['college'] as String,
      degree: map['degree'] as String,
      passingYear: map['passingYear'] as int,
      percentage: map['percentage'] as double,
    );
  }

  @override
  String toString() {
    return 'GraduationProfile(college: $college, degree: $degree, passingYear: $passingYear, percentage: $percentage)';
  }

  Education copyWith({
    String? college,
    String? degree,
    int? passingYear,
    double? percentage,
  }) {
    return Education(
      college: college ?? this.college,
      degree: degree ?? this.degree,
      passingYear: passingYear ?? this.passingYear,
      percentage: percentage ?? this.percentage,
    );
  }

  factory Education.empty() {
    return Education(college: '', degree: '', passingYear: 0, percentage: 0.0);
  }
}

class ExtraQualification {
  List<String> qualifications;

  ExtraQualification({required this.qualifications});

  Map<String, dynamic> toMap() {
    return {'qualifications': qualifications};
  }

  factory ExtraQualification.fromMap(Map<String, dynamic> map) {
    return ExtraQualification(
      qualifications: List<String>.from(map['qualifications']),
    );
  }

  @override
  String toString() {
    return 'ExtraQualification(qualifications: $qualifications)';
  }

  ExtraQualification copyWith({List<String>? qualifications}) {
    return ExtraQualification(
      qualifications: qualifications ?? this.qualifications,
    );
  }

  factory ExtraQualification.empty() {
    return ExtraQualification(qualifications: []);
  }
}

class EducationProfile {
  final Education? education;
  final ExtraQualification? extraQualification;

  EducationProfile({this.education, this.extraQualification});

  Map<String, dynamic> toMap() {
    return {
      'graduation': education?.toMap(),
      'extraQualification': extraQualification?.toMap(),
    };
  }

  factory EducationProfile.fromMap(Map<String, dynamic> map) {
    return EducationProfile(
      education: map['education'] != null
          ? Education.fromMap(map['education'] as Map<String, dynamic>)
          : null,
      extraQualification: map['extraQualification'] != null
          ? ExtraQualification.fromMap(
              map['extraQualification'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  String toString() {
    return 'EducationProfile(education: $education, extraQualification: $extraQualification)';
  }

  EducationProfile copyWith({
    Education? education,
    ExtraQualification? extraQualification,
  }) {
    return EducationProfile(
      education: education ?? this.education,
      extraQualification: extraQualification ?? this.extraQualification,
    );
  }

  factory EducationProfile.empty() {
    return EducationProfile(
      education: Education.empty(),
      extraQualification: ExtraQualification.empty(),
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
