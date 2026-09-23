import '../../../../translitration/models/bilingual_value.dart';

class EmploymentProfile {
  final BilingualValue jobType;
  final BilingualValue? company;
  final BilingualValue? designation;
  final BilingualValue? annualIncome;
  final BilingualValue? workLocation;
  final BilingualValue? districtEmployment;

  EmploymentProfile({
    required this.jobType,
    this.company,
    this.designation,
    this.annualIncome,
    this.workLocation,
    this.districtEmployment,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobType': jobType.toMap(),
      'company': company?.toMap(),
      'designation': designation?.toMap(),
      'annualIncome': annualIncome?.toMap(),
      'workLocation': workLocation?.toMap(),
      'districtEmployment': districtEmployment?.toMap(),
    };
  }

  factory EmploymentProfile.fromMap(Map<String, dynamic> map) {
    BilingualValue parseBilingual(dynamic val) {
      if (val is Map) {
        return BilingualValue.fromMap(Map<String, dynamic>.from(val));
      }
      return BilingualValue(en: val?.toString() ?? '', hi: '');
    }

    BilingualValue? parseOptionalBilingual(dynamic val) {
      if (val == null) return null;
      return parseBilingual(val);
    }

    return EmploymentProfile(
      jobType: parseBilingual(map['jobType']),
      company: parseOptionalBilingual(map['company']),
      designation: parseOptionalBilingual(map['designation']),
      annualIncome: parseOptionalBilingual(map['annualIncome']),
      workLocation: parseOptionalBilingual(map['workLocation']),
      districtEmployment: parseOptionalBilingual(map['districtEmployment']),
    );
  }

  @override
  String toString() {
    return 'EmploymentProfile(jobType: $jobType, company: $company, designation: $designation, annualIncome: $annualIncome, workLocation: $workLocation, districtEmployment: $districtEmployment)';
  }

  EmploymentProfile copyWith({
    BilingualValue? jobType,
    BilingualValue? company,
    BilingualValue? designation,
    BilingualValue? annualIncome,
    BilingualValue? workLocation,
    BilingualValue? districtEmployment,
  }) {
    return EmploymentProfile(
      jobType: jobType ?? this.jobType,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      annualIncome: annualIncome ?? this.annualIncome,
      workLocation: workLocation ?? this.workLocation,
      districtEmployment: districtEmployment ?? this.districtEmployment,
    );
  }

  factory EmploymentProfile.empty() {
    return EmploymentProfile(
      jobType: BilingualValue.empty(),
      company: null,
      designation: null,
      annualIncome: null,
      workLocation: null,
      districtEmployment: null,
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
