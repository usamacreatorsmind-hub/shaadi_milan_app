class AppUser {
  final String metrimonyId;
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String agentId;
  final String? profileId;
  final bool isVerified;
  final List<String>? wishlists;
  final UserStatus? userStatus;

  AppUser({
    required this.metrimonyId,

    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.agentId,
    this.profileId,
    this.isVerified = false,
    this.userStatus,

    this.wishlists,
  });

  Map<String, dynamic> toMap() {
    return {
      'metrimonyId': metrimonyId,

      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'agentId': agentId,
      'profileId': profileId,
      'isVerified': isVerified,
      'userStatus': userStatus?.toMap(),

      'wishlists': wishlists,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      metrimonyId: map['metrimonyId'] as String? ?? '',

      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      agentId: map['agentId'] as String? ?? '',
      profileId: map['profileId'] as String? ?? '',
      userStatus: map['userStatus'] != null
          ? UserStatus.fromMap(Map<String, dynamic>.from(map['userStatus']))
          : null,
      isVerified: map['isVerified'] as bool? ?? false,

      wishlists: (map['wishlists'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, metrimonyId: $metrimonyId,  fullName: $fullName, userStatus: $userStatus,wishlists: $wishlists, email: $email, role: $role, phone: $phone, agentId: $agentId, profileId: $profileId, isVerified: $isVerified)';
  }

  AppUser copyWith({
    String? uid,
    UserStatus? userStatus,
    String? metrimonyId,

    String? fullName,
    String? email,
    String? role,
    String? phone,
    String? agentId,
    String? profileId,
    List<String>? wishlists,

    bool? isVerified,
  }) {
    return AppUser(
      metrimonyId: metrimonyId ?? this.metrimonyId,

      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      userStatus: userStatus ?? this.userStatus,

      role: role ?? this.role,

      agentId: agentId ?? this.agentId,
      profileId: profileId ?? this.profileId,
      isVerified: isVerified ?? this.isVerified,
      wishlists: wishlists ?? this.wishlists,

      phone: phone ?? this.phone,
    );
  }

  static AppUser empty() {
    return AppUser(
      metrimonyId: '',

      uid: '',
      userStatus: UserStatus.empty(),

      fullName: '',
      email: '',
      role: '',
      phone: '',
      agentId: '',
      wishlists: [],
      profileId: '',
      isVerified: false,
    );
  }
}

class UserState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const UserState({this.user, this.isLoading = false, this.error});

  UserState copyWith({AppUser? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = UserState(user: null, isLoading: false, error: null);
}

class UserStatus {
  final bool isProfileCreated;
  final bool isApproved;
  final bool isRejected;

  const UserStatus({
    this.isProfileCreated = false,
    this.isApproved = false,
    this.isRejected = false,
  });

  // ---------------- COPY WITH ----------------
  UserStatus copyWith({
    bool? isProfileCreated,
    bool? isApproved,
    bool? isRejected,
  }) {
    return UserStatus(
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
      isApproved: isApproved ?? this.isApproved,
      isRejected: isRejected ?? this.isRejected,
    );
  }

  // ---------------- NAMED CONSTRUCTORS ----------------

  /// Profile created but pending approval
  factory UserStatus.created() {
    return const UserStatus(
      isProfileCreated: true,
      isApproved: false,
      isRejected: false,
    );
  }

  /// Approved profile
  factory UserStatus.approved() {
    return const UserStatus(
      isProfileCreated: true,
      isApproved: true,
      isRejected: false,
    );
  }

  /// Rejected profile
  factory UserStatus.rejected() {
    return const UserStatus(
      isProfileCreated: true,
      isApproved: false,
      isRejected: true,
    );
  }

  /// Initial empty status
  factory UserStatus.empty() {
    return const UserStatus(
      isProfileCreated: false,
      isApproved: false,
      isRejected: false,
    );
  }

  // ---------------- FIRESTORE ----------------

  Map<String, dynamic> toMap() {
    return {
      'isProfileCreated': isProfileCreated,
      'isApproved': isApproved,
      'isRejected': isRejected,
    };
  }

  factory UserStatus.fromMap(Map<String, dynamic> map) {
    return UserStatus(
      isProfileCreated: map['isProfileCreated'] as bool? ?? false,
      isApproved: map['isApproved'] as bool? ?? false,
      isRejected: map['isRejected'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'UserStatus(isProfileCreated: $isProfileCreated, '
        'isApproved: $isApproved, isRejected: $isRejected)';
  }
}
