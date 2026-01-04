class AgentProfile {
  final String role;
  final String uid;
  final String email;
  final String? photoUrl;
  final String agentId;
  final String agentName;
  final String agentAadhar;

  final String agentMobile;
  final DateTime registrationDate;

  final String address;

  AgentProfile({
    required this.address,

    required this.agentId,
    required this.agentName,
    required this.agentMobile,
    required this.registrationDate,
    required this.role,
    required this.agentAadhar,

    required this.uid,
    required this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
    'agentId': agentId,
    'address': address,
    'agentAadhar': agentAadhar,
    'agentName': agentName,
    'agentMobile': agentMobile,
    'registrationDate': registrationDate.toIso8601String(),
    'role': role,
    'uid': uid,
    'email': email,
    'agentAadhar': agentAadhar,
    'photoUrl': photoUrl,
  };

  factory AgentProfile.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.parse(val);
      if (val is DateTime) return val;
      try {
        // Handle Firestore Timestamp without direct dependency
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return AgentProfile(
      address: map['address'] ?? '',

      agentId: map['agentId'] ?? '',
      agentAadhar: map['agentAadhar'] ?? '',
      agentName: map['agentName'] ?? '',
      agentMobile: map['agentMobile'] ?? '',
      registrationDate: parseDate(map['registrationDate']),
      role: map['role'] ?? '',
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  @override
  String toString() {
    return 'AgentProfile(agentId: $agentId, agentAadhar: $agentAadhar, address: $address, agentName: $agentName, agentMobile: $agentMobile, registrationDate: $registrationDate, role: $role, uid: $uid, email: $email, photoUrl: $photoUrl)';
  }

  AgentProfile copyWith({
    String? address,
    String? agentId,
    String? agentName,
    String? agentMobile,
    DateTime? registrationDate,
    String? role,
    String? uid,
    String? agentAadhar,

    String? email,
    String? photoUrl,
  }) {
    return AgentProfile(
      address: address ?? this.address,

      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      agentAadhar: agentAadhar ?? this.agentAadhar,
      agentMobile: agentMobile ?? this.agentMobile,
      registrationDate: registrationDate ?? this.registrationDate,
      role: role ?? this.role,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory AgentProfile.empty() {
    return AgentProfile(
      address: '',

      agentId: '',
      agentName: '',
      agentMobile: '',
      agentAadhar: '',

      registrationDate: DateTime.now(),
      role: '',
      uid: '',
      email: '',
      photoUrl: null,
    );
  }
}
