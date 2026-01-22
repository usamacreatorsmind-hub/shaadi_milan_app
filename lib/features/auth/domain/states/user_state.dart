import 'package:cloud_firestore/cloud_firestore.dart';
// WishlistEntity.fromMapForViewer(
//   doc.data(),
//   viewerId: userId,
//   role: WishlistViewerRole.senderUser,
// );

// WishlistEntity.fromMapForViewer(
//   doc.data(),
//   viewerId: userId,
//   role: WishlistViewerRole.receiverUser,
// );

// final role = resolveAgentRole(doc.data(), agentId);

// WishlistEntity.fromMapForViewer(
//   doc.data(),
//   viewerId: agentId,
//   role: role,
// );

WishlistViewerRole resolveAgentRole(Map<String, dynamic> map, String agentId) {
  if (map['senderAgent'] == agentId) {
    return WishlistViewerRole.senderAgent;
  }
  return WishlistViewerRole.receiverAgent;
}

enum WishlistViewerRole { senderUser, receiverUser, senderAgent, receiverAgent }

// Wishlist status example
enum WishlistStatus {
  pending, // User liked profile (agent not contacted yet)
  contacted, // Agent contacted user
  interested, // User confirmed interest
  notInterested, // User declined after contact
  closed, // Lead finished
}

class WishlistState {
  WishlistEntity? wishlistEntity;
  bool isLoading;
  String? error;

  WishlistState({this.wishlistEntity, this.isLoading = false, this.error});

  WishlistState copyWith({
    WishlistEntity? wishlistEntity,
    bool? isLoading,
    String? error,
  }) {
    return WishlistState(
      wishlistEntity: wishlistEntity ?? this.wishlistEntity,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static final initial = WishlistState(
    wishlistEntity: null,
    isLoading: false,
    error: null,
  );
}

class WishlistEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String receiverAgent;
  final String senderAgent;
  final DateTime updatedAt;
  final String status;

  WishlistEntity({
    this.id = '',
    required this.senderId,
    required this.receiverId,
    required this.receiverAgent,
    required this.senderAgent,
    required this.updatedAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'receiverAgent': receiverAgent,
      'senderAgent': senderAgent,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory WishlistEntity.fromMapForViewer(
    Map<String, dynamic> map, {
    required String viewerId,
    required WishlistViewerRole role,
  }) {
    final id = map['id'] ?? '';
    final senderId = map['senderId'] ?? '';
    final receiverId = map['receiverId'] ?? '';

    final senderAgent = map['senderAgent'] ?? '';
    final receiverAgent = map['receiverAgent'] ?? '';

    final updatedAt = _parseDateTime(map['updatedAt']);
    final status = map['status'] ?? WishlistStatus.pending.name;

    switch (role) {
      // ───── USER ─────
      case WishlistViewerRole.senderUser:
        return WishlistEntity(
          id: id,
          senderId: receiverId,
          receiverId: senderId,
          senderAgent: receiverAgent,
          receiverAgent: senderAgent,
          updatedAt: updatedAt,
          status: status,
        );

      case WishlistViewerRole.receiverUser:
        return WishlistEntity(
          id: id,
          senderId: senderId,
          receiverId: receiverId,
          senderAgent: senderAgent,
          receiverAgent: receiverAgent,
          updatedAt: updatedAt,
          status: status,
        );

      // ───── AGENT ─────
      case WishlistViewerRole.senderAgent:
        // agent represents sender → sender is "me"
        return WishlistEntity(
          id: id,
          senderId: receiverId,
          receiverId: senderId,
          senderAgent: receiverAgent,
          receiverAgent: senderAgent,
          updatedAt: updatedAt,
          status: status,
        );

      case WishlistViewerRole.receiverAgent:
        // agent represents receiver → receiver is "me"
        return WishlistEntity(
          id: id,
          senderId: senderId,
          receiverId: receiverId,
          senderAgent: senderAgent,
          receiverAgent: receiverAgent,
          updatedAt: updatedAt,
          status: status,
        );
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed);
      }
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  WishlistEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? receiverAgent,
    String? senderAgent,
    DateTime? updatedAt,
    String? status,
  }) {
    return WishlistEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      receiverAgent: receiverAgent ?? this.receiverAgent,
      senderAgent: senderAgent ?? this.senderAgent,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'WishlistEntity(id: $id, senderId: $senderId, receiverId: $receiverId, '
        'receiverAgent: $receiverAgent, senderAgent: $senderAgent, '
        'updatedAt: $updatedAt, status: $status)';
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
  final String profileStatus;
  final bool isProfileCreated;
  final String metrimonyId;
  final String profileId;

  final DateTime createdAt;
  final DateTime lastSeen;

  const UserEntity({
    required this.profileStatus,
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
    required this.createdAt,
    required this.lastSeen,
  });

  /// EMPTY
  factory UserEntity.empty() => UserEntity(
    profileStatus: 'active',
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
      profileStatus: map['profileStatus'] ?? 'active',
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
    String? profileStatus,
    String? phone,
    String? agentId,
    String? userType,
    String? role,
    String? profileImageUrl,
    bool? isProfileCreated,
    String? metrimonyId,
    String? profileId,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserEntity(
      profileStatus: profileStatus ?? this.profileStatus,

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
