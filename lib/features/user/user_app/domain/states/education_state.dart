import '../../../../translitration/models/bilingual_value.dart';

class Education {
  final BilingualValue college;
  final BilingualValue course;
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
      'college': college.toMap(),
      'course': course.toMap(),
      'percentage': percentage,
      'passingYear': passingYear,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      college: map['college'] != null && map['college'] is Map
          ? BilingualValue.fromMap(Map<String, dynamic>.from(map['college']))
          : BilingualValue.empty(),
      course: map['course'] != null && map['course'] is Map
          ? BilingualValue.fromMap(Map<String, dynamic>.from(map['course']))
          : BilingualValue.empty(),
      passingYear: int.tryParse(map['passingYear']?.toString() ?? '') ?? 0,
      percentage: double.tryParse(map['percentage']?.toString() ?? '') ?? 0.0,
    );
  }

  factory Education.empty() {
    return Education(
      college: BilingualValue.empty(),
      course: BilingualValue.empty(),
      passingYear: 0,
      percentage: 0.0,
    );
  }

  @override
  String toString() {
    return 'Education(college: $college, course: $course, passingYear: $passingYear, percentage: $percentage)';
  }
}

class ExtraQualification {
  final List<BilingualValue> qualifications;

  ExtraQualification({required this.qualifications});

  Map<String, dynamic> toMap() {
    return {'qualifications': qualifications.map((q) => q.toMap()).toList()};
  }

  factory ExtraQualification.fromMap(Map<String, dynamic> map) {
    return ExtraQualification(
      qualifications: (map['qualifications'] as List? ?? [])
          .map(
            (q) => q is Map
                ? BilingualValue.fromMap(Map<String, dynamic>.from(q))
                : BilingualValue(hi: q.toString(), en: q.toString()),
          )
          .toList(),
    );
  }

  factory ExtraQualification.empty() => ExtraQualification(qualifications: []);

  @override
  String toString() {
    return 'ExtraQualification(qualifications: $qualifications)';
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
      isIlletrate: map['isIlletrate'] as bool? ?? false,
    );
  }

  factory EducationProfile.empty() {
    return EducationProfile(
      isIlletrate: false,
      education: Education.empty(),
      extraQualification: null,
    );
  }

  @override
  String toString() {
    return 'EducationProfile(isIlletrate: $isIlletrate, education: $education, extraQualification: $extraQualification)';
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
