class IdentityProfile {
  final String profileId;
  final String gender;
  final DateTime dob;
  final int age;
  final String aadhar;

  IdentityProfile({
    required this.profileId,
    required this.gender,
    required this.dob,
    required this.age,
    required this.aadhar,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'gender': gender,
      'dob': dob.toIso8601String(),
      'age': age,
      'aadhar': aadhar,
    };
  }

  factory IdentityProfile.fromMap(Map<String, dynamic> map) {
    return IdentityProfile(
      profileId: map['profileId'] as String,
      gender: map['gender'] as String,
      dob: DateTime.parse(map['dob'] as String),
      age: map['age'] as int,
      aadhar: map['aadhar'] as String,
    );
  }

  IdentityProfile copyWith({
    String? profileId,
    String? gender,
    DateTime? dob,
    int? age,
    String? aadhar,
  }) {
    return IdentityProfile(
      profileId: profileId ?? this.profileId,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      aadhar: aadhar ?? this.aadhar,
    );
  }

  static IdentityProfile empty() {
    return IdentityProfile(
      profileId: '',
      gender: '',
      dob: DateTime(1900),
      age: 0,
      aadhar: '',
    );
  }
}

class IdentityState {
  final IdentityProfile? identity;
  final bool isLoading;
  final String? error;

  const IdentityState({this.identity, this.isLoading = false, this.error});

  IdentityState copyWith({
    IdentityProfile? identity,
    bool? isLoading,
    String? error,
  }) {
    return IdentityState(
      identity: identity ?? this.identity,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = IdentityState();
}
