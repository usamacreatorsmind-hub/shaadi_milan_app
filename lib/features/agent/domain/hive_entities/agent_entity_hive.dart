import 'package:arvika_marriage_bureau/features/agent/domain/states/agent_entity.dart'; 
import 'package:hive/hive.dart';

part 'agent_entity_hive.g.dart';

@HiveType(typeId: 11)
class AgentEntityHive extends HiveObject {
  @HiveField(0)
  late String agentId;

  @HiveField(1)
  late String agentName;

  @HiveField(2)
  late String agentMobile;
  @HiveField(3)
  late DateTime registrationDate;

  @HiveField(4)
  late String role;

  @HiveField(5)
  late String uid;

  @HiveField(6)
  late String email;

  @HiveField(7)
  late String? photoUrl;

  AgentEntityHive({
    required this.agentId,
    required this.agentName,
    required this.agentMobile,
    required this.registrationDate,
    required this.role,
    required this.uid,
    required this.email,
    this.photoUrl,
  });

  AgentProfile toDomain() {
    return AgentProfile(
      agentId: agentId,
      agentName: agentName,
      agentMobile: agentMobile,
      registrationDate: registrationDate,
      role: role,
      uid: uid,
      email: email,
      photoUrl: photoUrl,
    );
  }

  factory AgentEntityHive.fromDomain(AgentProfile profile) {
    return AgentEntityHive(
      agentId: profile.agentId,
      agentName: profile.agentName,
      agentMobile: profile.agentMobile,
      registrationDate: profile.registrationDate,
      role: profile.role,
      uid: profile.uid,
      email: profile.email,
      photoUrl: profile.photoUrl,
    );
  }

  @override
  String toString() {
    return 'AgentEntityHive(agentId: $agentId, agentName: $agentName, agentMobile: $agentMobile, registrationDate: $registrationDate, role: $role, uid: $uid, email: $email, photoUrl: $photoUrl)';
  }

  AgentEntityHive copyWith({
    String? agentId,
    String? agentName,
    String? agentMobile,
    DateTime? registrationDate,
    String? role,
    String? uid,
    String? email,
    String? photoUrl,
  }) {
    return AgentEntityHive(
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

  Map<String, dynamic> toMap() {
    return {
      'agentId': agentId,
      'agentName': agentName,
      'agentMobile': agentMobile,
      'registrationDate': registrationDate.toIso8601String(),
      'role': role,
      'uid': uid,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory AgentEntityHive.fromMap(Map<String, dynamic> map) {
    return AgentEntityHive(
      agentId: map['agentId'] as String,
      agentName: map['agentName'] as String,
      agentMobile: map['agentMobile'] as String,
      registrationDate: DateTime.parse(map['registrationDate'] as String),
      role: map['role'] as String,
      uid: map['uid'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }
}
