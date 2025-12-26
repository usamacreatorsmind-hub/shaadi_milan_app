class Metriculation {
  final String schoolName;
  final String board;
  final double percentage;
  final int passingYear;

  Metriculation({
    required this.schoolName,
    required this.board,
    required this.percentage,
    required this.passingYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'board': board,
      'percentage': percentage,
      'passingYear': passingYear,
    };
  }

  factory Metriculation.fromMap(Map<String, dynamic> map) {
    return Metriculation(
      schoolName: map['schoolName'] as String,
      board: map['board'] as String,
      percentage: map['percentage'] as double,
      passingYear: map['passingYear'] as int,
    );
  }

  @override
  String toString() {
    return 'MetriculationProfile(schoolName: $schoolName, board: $board, percentage: $percentage, passingYear: $passingYear)';
  }

  Metriculation copyWith({
    String? schoolName,
    String? board,
    double? percentage,
    int? passingYear,
  }) {
    return Metriculation(
      schoolName: schoolName ?? this.schoolName,
      board: board ?? this.board,
      percentage: percentage ?? this.percentage,
      passingYear: passingYear ?? this.passingYear,
    );
  }

  factory Metriculation.empty() {
    return Metriculation(
      schoolName: '',
      board: '',
      percentage: 0.0,
      passingYear: 0,
    );
  }
}

class IntremidiateProfile {
  final String collegeName;
  final String board;
  final double percentage;
  final int passingYear;

  IntremidiateProfile({
    required this.collegeName,
    required this.board,
    required this.percentage,
    required this.passingYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'collegeName': collegeName,
      'board': board,
      'percentage': percentage,
      'passingYear': passingYear,
    };
  }

  factory IntremidiateProfile.fromMap(Map<String, dynamic> map) {
    return IntremidiateProfile(
      collegeName: map['collegeName'] as String,
      board: map['board'] as String,
      percentage: map['percentage'] as double,
      passingYear: map['passingYear'] as int,
    );
  }

  @override
  String toString() {
    return 'IntremidiateProfile(collegeName: $collegeName, board: $board, percentage: $percentage, passingYear: $passingYear)';
  }

  IntremidiateProfile copyWith({
    String? collegeName,
    String? board,
    double? percentage,
    int? passingYear,
  }) {
    return IntremidiateProfile(
      collegeName: collegeName ?? this.collegeName,
      board: board ?? this.board,
      percentage: percentage ?? this.percentage,
      passingYear: passingYear ?? this.passingYear,
    );
  }

  factory IntremidiateProfile.empty() {
    return IntremidiateProfile(
      collegeName: '',
      board: '',
      percentage: 0.0,
      passingYear: 0,
    );
  }
}

class Graduation {
  final String college;
  final String degree;
  final int passingYear;
  final double percentage;

  Graduation({
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

  factory Graduation.fromMap(Map<String, dynamic> map) {
    return Graduation(
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

  Graduation copyWith({
    String? college,
    String? degree,
    int? passingYear,
    double? percentage,
  }) {
    return Graduation(
      college: college ?? this.college,
      degree: degree ?? this.degree,
      passingYear: passingYear ?? this.passingYear,
      percentage: percentage ?? this.percentage,
    );
  }

  factory Graduation.empty() {
    return Graduation(college: '', degree: '', passingYear: 0, percentage: 0.0);
  }
}

class EducationProfile {
  final Metriculation? metriculation;
  final IntremidiateProfile? intremidiate;
  final Graduation? graduation;

  EducationProfile({this.metriculation, this.intremidiate, this.graduation});

  Map<String, dynamic> toMap() {
    return {
      'metriculation': metriculation?.toMap(),
      'intremidiate': intremidiate?.toMap(),
      'graduation': graduation?.toMap(),
    };
  }

  factory EducationProfile.fromMap(Map<String, dynamic> map) {
    return EducationProfile(
      metriculation: map['metriculation'] != null
          ? Metriculation.fromMap(map['metriculation'] as Map<String, dynamic>)
          : null,
      intremidiate: map['intremidiate'] != null
          ? IntremidiateProfile.fromMap(
              map['intremidiate'] as Map<String, dynamic>,
            )
          : null,
      graduation: map['graduation'] != null
          ? Graduation.fromMap(map['graduation'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'EducationProfile(metriculation: $metriculation, intremidiate: $intremidiate, graduation: $graduation)';
  }

  EducationProfile copyWith({
    Metriculation? metriculation,
    IntremidiateProfile? intremidiate,
    Graduation? graduation,
  }) {
    return EducationProfile(
      metriculation: metriculation ?? this.metriculation,
      intremidiate: intremidiate ?? this.intremidiate,
      graduation: graduation ?? this.graduation,
    );
  }

  factory EducationProfile.empty() {
    return EducationProfile(
      metriculation: Metriculation.empty(),
      intremidiate: IntremidiateProfile.empty(),
      graduation: Graduation.empty(),
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
