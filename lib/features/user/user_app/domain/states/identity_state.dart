import '../../../../translitration/models/bilingual_value.dart';

class IdentityProfile {
  final String profileId;
  final BilingualValue gender;
  final BilingualValue firstName;
  final BilingualValue lastName;
  final BilingualValue birthplace;
  final BilingualValue maritalStatus;
  final DateTime dob;
  final int age;
  final String tob;
  final String profileManagedBy;
  final List<String> alternatePhones;

  IdentityProfile({
    required this.profileId,
    required this.gender,
    required this.firstName,
    required this.lastName,
    BilingualValue? birthplace,
    BilingualValue? maritalStatus,
    required this.dob,
    required this.age,
    this.tob = "",
    this.profileManagedBy = "Self",
    this.alternatePhones = const [],
  }) : birthplace = birthplace ?? BilingualValue.empty(),
       maritalStatus = maritalStatus ?? BilingualValue.empty();

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'gender': gender.toMap(),
      'firstName': firstName.toMap(),
      'lastName': lastName.toMap(),
      'birthplace': birthplace.toMap(),
      'maritalStatus': maritalStatus.toMap(),
      'dob': dob.toIso8601String(),
      'age': age,
      'tob': tob,
      'profileManagedBy': profileManagedBy,
      'alternatePhones': alternatePhones,
    };
  }

  @override
  String toString() {
    return 'Name: $firstName $lastName, Birthplace: $birthplace, MaritalStatus: $maritalStatus, Gender: $gender, DOB: ${dob.toLocal().toString().split(' ')[0]}, Age: $age, TOB: $tob, ManagedBy: $profileManagedBy, AlternatePhones: $alternatePhones';
  }

  factory IdentityProfile.fromMap(Map<String, dynamic> map) {
    BilingualValue parseBilingual(dynamic val) {
      if (val is Map) {
        return BilingualValue.fromMap(Map<String, dynamic>.from(val));
      }
      return BilingualValue(en: val?.toString() ?? '', hi: '');
    }

    return IdentityProfile(
      profileId: map['profileId'] as String? ?? '',
      gender: parseBilingual(map['gender']),
      firstName: parseBilingual(map['firstName']),
      lastName: parseBilingual(map['lastName']),
      birthplace: parseBilingual(map['birthplace']),
      maritalStatus: parseBilingual(map['maritalStatus']),
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'].toString()) ?? DateTime(1900) : DateTime(1900),
      age: map['age'] as int? ?? 0,
      tob: map['tob'] as String? ?? '',
      profileManagedBy: map['profileManagedBy'] as String? ?? 'Self',
      alternatePhones: List<String>.from(map['alternatePhones'] ?? []),
    );
  }

  IdentityProfile copyWith({
    String? profileId,
    BilingualValue? gender,
    BilingualValue? firstName,
    BilingualValue? lastName,
    BilingualValue? birthplace,
    BilingualValue? maritalStatus,
    DateTime? dob,
    int? age,
    String? tob,
    String? profileManagedBy,
    List<String>? alternatePhones,
  }) {
    return IdentityProfile(
      profileId: profileId ?? this.profileId,
      gender: gender ?? this.gender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthplace: birthplace ?? this.birthplace,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      tob: tob ?? this.tob,
      profileManagedBy: profileManagedBy ?? this.profileManagedBy,
      alternatePhones: alternatePhones ?? this.alternatePhones,
    );
  }

  factory IdentityProfile.empty() {
    return IdentityProfile(
      profileId: '',
      gender: BilingualValue.empty(),
      firstName: BilingualValue.empty(),
      lastName: BilingualValue.empty(),
      birthplace: BilingualValue.empty(),
      maritalStatus: BilingualValue.empty(),
      dob: DateTime(1900),
      age: 0,
      tob: '',
      profileManagedBy: 'Self',
      alternatePhones: [],
    );
  }
}

class IdentityState {
  final IdentityProfile? identity;
  final bool isLoading;
  final String? error;

  const IdentityState({this.identity, this.isLoading = false, this.error});

  IdentityState copyWith({IdentityProfile? identity, bool? isLoading, String? error}) {
    return IdentityState(identity: identity ?? this.identity, isLoading: isLoading ?? this.isLoading, error: error);
  }

  static const initial = IdentityState();
}
