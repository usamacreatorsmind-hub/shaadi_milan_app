import '../../../../translitration/models/bilingual_value.dart';

class IdentityProfile {
  final String profileId;
  final BilingualValue gender;
  final BilingualValue firstName;
  final BilingualValue lastName;
  final DateTime dob;
  final int age;

  IdentityProfile({
    required this.profileId,
    required this.gender,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'gender': gender.toMap(),
      'firstName': firstName.toMap(),
      'lastName': lastName.toMap(),
      'dob': dob.toIso8601String(),
      'age': age,
    };
  }

  @override
  String toString() {
    return 'Name: $firstName $lastName, Gender: $gender, DOB: ${dob.toLocal().toString().split(' ')[0]}, Age: $age';
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
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'].toString()) ?? DateTime(1900) : DateTime(1900),
      age: map['age'] as int? ?? 0,
    );
  }

  IdentityProfile copyWith({
    String? profileId,
    BilingualValue? gender,
    BilingualValue? firstName,
    BilingualValue? lastName,
    DateTime? dob,
    int? age,
  }) {
    return IdentityProfile(
      profileId: profileId ?? this.profileId,
      gender: gender ?? this.gender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      age: age ?? this.age,
    );
  }

  factory IdentityProfile.empty() {
    return IdentityProfile(
      profileId: '',
      gender: BilingualValue.empty(),
      firstName: BilingualValue.empty(),
      lastName: BilingualValue.empty(),
      dob: DateTime(1900),
      age: 0,
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
