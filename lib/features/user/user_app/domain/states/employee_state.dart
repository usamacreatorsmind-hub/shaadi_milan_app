class EmploymentProfile {
  final String jobType;
  final String? company;
  final String? designation;
  final int? annualIncome;
  final String? workLocation;

  EmploymentProfile({
    required this.jobType,
    this.company,
    this.designation,
    this.annualIncome,
    this.workLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobType': jobType,
      'company': company,
      'designation': designation,
      'annualIncome': annualIncome,
      'workLocation': workLocation,
    };
  }

  factory EmploymentProfile.fromMap(Map<String, dynamic> map) {
    return EmploymentProfile(
      jobType: map['jobType'] as String? ?? '',
      company: map['company'] as String?,
      designation: map['designation'] as String?,
      annualIncome: int.tryParse(map['annualIncome']?.toString() ?? ''),
      workLocation: map['workLocation'] as String?,
    );
  }

  @override
  String toString() {
    return 'EmploymentProfile(jobType: $jobType, company: $company, designation: $designation, annualIncome: $annualIncome, workLocation: $workLocation)';
  }

  EmploymentProfile copyWith({
    String? jobType,
    String? company,
    String? designation,
    int? annualIncome,
    String? workLocation,
  }) {
    return EmploymentProfile(
      jobType: jobType ?? this.jobType,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      annualIncome: annualIncome ?? this.annualIncome,
      workLocation: workLocation ?? this.workLocation,
    );
  }

  factory EmploymentProfile.empty() {
    return EmploymentProfile(
      jobType: 'Not Working',
      company: null,
      designation: null,
      annualIncome: null,
      workLocation: null,
    );
  }
}

class EmploymentState {
  final EmploymentProfile? employment;
  final bool isLoading;
  final String? error;

  const EmploymentState({this.employment, this.isLoading = false, this.error});

  EmploymentState copyWith({
    EmploymentProfile? employment,
    bool? isLoading,
    String? error,
  }) {
    return EmploymentState(
      employment: employment ?? this.employment,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = EmploymentState(
    employment: null,
    isLoading: false,
    error: null,
  );
}
