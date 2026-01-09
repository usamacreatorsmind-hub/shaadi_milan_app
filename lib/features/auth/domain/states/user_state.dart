import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserEntity {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String agentId;
  final String userType;
  final String role;

  final bool isProfileCreated;

  final String metrimonyId;
  final String profileId;
  // primary wishlist
  final List<String> wishlists; // secondary (if required)

  final DateTime createdAt;
  final DateTime lastSeen;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.agentId,
    required this.userType,
    required this.role,
    required this.isProfileCreated,
    required this.metrimonyId,
    required this.profileId,
    required this.wishlists,
    required this.createdAt,
    required this.lastSeen,
  });

  /// ------------------ EMPTY ------------------
  factory UserEntity.empty() {
    return UserEntity(
      uid: '',
      email: '',
      fullName: '',
      phone: '',
      agentId: '',
      userType: '',
      role: '',
      isProfileCreated: false,
      metrimonyId: '',
      profileId: '',

      wishlists: const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      lastSeen: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// ------------------ MAP ------------------
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'agentId': agentId,
      'userType': userType,
      'role': role,
      'isProfileCreated': isProfileCreated,
      'metrimonyId': metrimonyId,
      'profileId': profileId,

      'wishlists': wishlists,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserEntity.empty();

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return UserEntity(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      agentId: map['agentId'] ?? '',
      userType: map['userType'] ?? '',
      role: map['role'] ?? '',
      isProfileCreated: map['isProfileCreated'] ?? false,
      metrimonyId: map['metrimonyId'] ?? '',
      profileId: map['profileId'] ?? '',

      wishlists: List<String>.from(map['wishlists'] ?? const []),
      createdAt: parseDate(map['createdAt']),
      lastSeen: parseDate(map['lastSeen']),
    );
  }

  /// ------------------ JSON ------------------
  String toJson() => json.encode(toMap());

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source));

  /// ------------------ COPY WITH ------------------
  UserEntity copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    String? agentId,
    String? userType,
    String? role,
    bool? isProfileCreated,
    String? metrimonyId,
    String? profileId,
    List<String>? wishlists,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      agentId: agentId ?? this.agentId,
      userType: userType ?? this.userType,
      role: role ?? this.role,
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
      metrimonyId: metrimonyId ?? this.metrimonyId,
      profileId: profileId ?? this.profileId,

      wishlists: wishlists ?? this.wishlists,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// ------------------ OVERRIDES ------------------
  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, fullName: $fullName, userType: $userType, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.uid == uid &&
        other.email == email &&
        other.fullName == fullName &&
        other.phone == phone &&
        other.agentId == agentId &&
        other.userType == userType &&
        other.role == role &&
        other.isProfileCreated == isProfileCreated &&
        other.metrimonyId == metrimonyId &&
        other.profileId == profileId &&
        listEquals(other.wishlists, wishlists) &&
        other.createdAt == createdAt &&
        other.lastSeen == lastSeen;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        phone.hashCode ^
        agentId.hashCode ^
        userType.hashCode ^
        role.hashCode ^
        isProfileCreated.hashCode ^
        metrimonyId.hashCode ^
        profileId.hashCode ^
        wishlists.hashCode ^
        createdAt.hashCode ^
        lastSeen.hashCode;
  }
}

/// ================= USER STATE =================

class UserState {
  final UserEntity user;

  const UserState({required this.user});

  factory UserState.empty() => UserState(user: UserEntity.empty());

  UserState copyWith({UserEntity? user}) {
    return UserState(user: user ?? this.user);
  }
}
