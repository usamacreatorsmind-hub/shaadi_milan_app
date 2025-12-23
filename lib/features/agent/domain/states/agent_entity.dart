 
import 'package:arvika_marriage_bureau/features/agent/domain/hive_entities/agent_entity_hive.dart';

class AgentProfile {
  final String role;
  final String uid;
  final String email;
  final String? photoUrl;
  final String agentId;
  final String agentName;
  final String agentMobile;
  final DateTime registrationDate;

  AgentProfile({
    required this.agentId,
    required this.agentName,
    required this.agentMobile,
    required this.registrationDate,
    required this.role,
    required this.uid,
    required this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
    'agentId': agentId,
    'agentName': agentName,
    'agentMobile': agentMobile,
    'registrationDate': registrationDate.toIso8601String(),
    'role': role,
    'uid': uid,
    'email': email,
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
      agentId: map['agentId'] ?? '',
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
    return 'AgentProfile(agentId: $agentId, agentName: $agentName, agentMobile: $agentMobile, registrationDate: $registrationDate, role: $role, uid: $uid, email: $email, photoUrl: $photoUrl)';
  }

  AgentProfile copyWith({
    String? agentId,
    String? agentName,
    String? agentMobile,
    DateTime? registrationDate,
    String? role,
    String? uid,
    String? email,
    String? photoUrl,
  }) {
    return AgentProfile(
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
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
      agentId: '',
      agentName: '',
      agentMobile: '',
      registrationDate: DateTime.now(),
      role: '',
      uid: '',
      email: '',
      photoUrl: null,
    );
  }

  AgentEntityHive toHive() {
    return AgentEntityHive.fromDomain(this);
  }
}
