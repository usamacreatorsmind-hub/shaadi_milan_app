import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';

// status
// wishlist status example
enum WishlistStatus {
  pending, // User liked profile (agent not contacted yet)
  contacted, // Agent contacted user
  interested, // User confirmed interest
  notInterested, // User declined after contact
  closed, // Lead finished
}

class WishListItem {
  final String profileId;

  final DateTime updatedAt;
  final String status;
  WishListItem({
    required this.status,
    required this.profileId,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory WishListItem.fromMap(Map<String, dynamic> map) {
    return WishListItem(
      status: map['status'] ?? '',
      profileId: map['profileId'] ?? '',
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return DateTime.fromMillisecondsSinceEpoch(parsed);
    }
    if (value is Timestamp) return value.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  WishListItem copyWith({
    String? profileId,
    DateTime? updatedAt,
    String? status,
  }) {
    return WishListItem(
      profileId: profileId ?? this.profileId,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'WishListItem(profileId: $profileId, updatedAt: $updatedAt, status: $status,)';
  }
}

class UserEntity {
  final String uid;
  final String email;
  final String gender;
  final String fullName;
  final String phone;
  final String agentId;
  final String userType;
  final String role;
  final String profileImageUrl;

  final bool isProfileCreated;
  final String metrimonyId;
  final String profileId;

  final List<WishListItem> wishlists;

  final DateTime createdAt;
  final DateTime lastSeen;

  const UserEntity({
    required this.gender,
    required this.profileImageUrl,
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

  /// EMPTY
  factory UserEntity.empty() => UserEntity(
    profileImageUrl: '',
    gender: "",
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

  /// MAP
  Map<String, dynamic> toMap() {
    return {
      'profileImageUrl': profileImageUrl,
      'uid': uid,
      'gender': gender,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'agentId': agentId,
      'userType': userType,
      'role': role,
      'isProfileCreated': isProfileCreated,
      'metrimonyId': metrimonyId,
      'profileId': profileId,
      'wishlists': wishlists.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserEntity.empty();

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return UserEntity(
      profileImageUrl: map['profileImageUrl'] ?? '',
      uid: map['uid'] ?? '',
      gender: map['gender'],
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      agentId: map['agentId'] ?? '',
      userType: map['userType'] ?? '',
      role: map['role'] ?? '',
      isProfileCreated: map['isProfileCreated'] ?? false,
      metrimonyId: map['metrimonyId'] ?? '',
      profileId: map['profileId'] ?? '',
      wishlists:
          (map['wishlists'] as List<dynamic>?)
              ?.map((e) => WishListItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: parseDate(map['createdAt']),
      lastSeen: parseDate(map['lastSeen']),
    );
  }

  /// COPY WITH
  UserEntity copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? gender,

    String? phone,
    String? agentId,
    String? userType,
    String? role,
    String? profileImageUrl,
    bool? isProfileCreated,
    String? metrimonyId,
    String? profileId,
    List<WishListItem>? wishlists,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserEntity(
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      gender: gender ?? this.gender,
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
