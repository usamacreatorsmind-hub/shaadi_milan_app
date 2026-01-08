class Education {
  final String college;
  final String course;
  final int passingYear;
  final double percentage;

  Education({
    required this.college,
    required this.course,
    required this.passingYear,
    required this.percentage,
  });
  Map<String, dynamic> toMap() {
    return {
      'college': college,
      'course': course,
      'percentage': percentage,
      'passingYear': passingYear,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      college: map['college'] as String,
      course: map['course'] as String,
      passingYear: map['passingYear'] as int,
      percentage: map['percentage'] as double,
    );
  }

  @override
  String toString() {
    return 'EducationProfile(college: $college, course: $course, passingYear: $passingYear, percentage: $percentage)';
  }

  Education copyWith({
    String? college,
    String? degree,
    int? passingYear,
    double? percentage,
  }) {
    return Education(
      college: college ?? this.college,
      course: degree ?? course,
      passingYear: passingYear ?? this.passingYear,
      percentage: percentage ?? this.percentage,
    );
  }

  factory Education.empty() {
    return Education(college: '', course: '', passingYear: 0, percentage: 0.0);
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
  final bool isIlletrate;
  final Education? education;
  final ExtraQualification? extraQualification;

  EducationProfile({
    this.education,
    required this.isIlletrate,
    this.extraQualification,
  });

  Map<String, dynamic> toMap() {
    return {
      'education': education?.toMap(),
      'extraQualification': extraQualification?.toMap(),
      'isIlletrate': isIlletrate,
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

      isIlletrate: map['isIlletrate'] as bool,
    );
  }

  @override
  String toString() {
    return 'EducationProfile(education: $education, isIlletrate: $isIlletrate'
        '  extraQualification: $extraQualification)';
  }

  EducationProfile copyWith({
    Education? education,
    ExtraQualification? extraQualification,
    bool? isIlletrate,
  }) {
    return EducationProfile(
      education: education ?? this.education,
      isIlletrate: isIlletrate ?? this.isIlletrate,
      extraQualification: extraQualification ?? this.extraQualification,
    );
  }

  factory EducationProfile.empty() {
    return EducationProfile(
      isIlletrate: false,

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
