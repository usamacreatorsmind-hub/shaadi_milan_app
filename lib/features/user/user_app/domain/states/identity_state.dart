class IdentityProfile {
  final String profileId;
  final String gender;
  final DateTime dob;
  final int age;
  final String aboutMe;
  final String aadhar;

  IdentityProfile({
    required this.profileId,
    required this.gender,

    required this.aboutMe,

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
      'aboutMe': aboutMe,
    };
  }

  @override
  String toString() {
    return 'Gender: $gender,  aboutMe: $aboutMe,    DOB: ${dob.toLocal().toString().split(' ')[0]}, Age: $age, Aadhar: $aadhar';
  }

  factory IdentityProfile.fromMap(Map<String, dynamic> map) {
    return IdentityProfile(
      aboutMe: map['aboutMe'] as String? ?? '',

      profileId: map['profileId'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      dob: map['dob'] != null
          ? DateTime.tryParse(map['dob'].toString()) ?? DateTime(1900)
          : DateTime(1900),
      age: map['age'] as int? ?? 0,
      aadhar: map['aadhar'] as String? ?? '',
    );
  }

  IdentityProfile copyWith({
    String? profileId,
    String? gender,
    DateTime? dob,
    String? aboutMe,

    String? profileImageUrl,

    int? age,
    String? aadhar,
  }) {
    return IdentityProfile(
      aboutMe: aboutMe ?? this.aboutMe,

      profileId: profileId ?? this.profileId,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      age: age ?? this.age,

      aadhar: aadhar ?? this.aadhar,
    );
  }

  factory IdentityProfile.empty() {
    return IdentityProfile(
      aboutMe: '',

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
