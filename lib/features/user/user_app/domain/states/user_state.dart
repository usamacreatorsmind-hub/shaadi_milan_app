class AppUser {
  final String metrimonyId;
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String agentId;
  final String? profileId;
  final List<String>? wishlists;

  final bool isProfileCreated;

  AppUser({
    required this.metrimonyId,
    required this.isProfileCreated,

    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.agentId,
    this.profileId,

    this.wishlists,
  });

  Map<String, dynamic> toMap() {
    return {
      'metrimonyId': metrimonyId,
      'isProfileCreated': isProfileCreated,

      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'agentId': agentId,
      'profileId': profileId,

      'wishlists': wishlists,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      metrimonyId: map['metrimonyId'] as String? ?? '',
      isProfileCreated: map['isProfileCreated'] as bool? ?? false,

      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      agentId: map['agentId'] as String? ?? '',
      profileId: map['profileId'] as String? ?? '',

      wishlists: (map['wishlists'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, metrimonyId: $metrimonyId, isProfileCreated: $isProfileCreated, fullName: $fullName,  wishlists: $wishlists, email: $email, role: $role, phone: $phone, agentId: $agentId, profileId: $profileId,  )';
  }

  AppUser copyWith({
    String? uid,
    String? metrimonyId,

    String? fullName,
    String? email,
    String? role,
    String? phone,
    String? agentId,
    String? profileId,
    List<String>? wishlists,
    bool? isProfileCreated,

    bool? isVerified,
  }) {
    return AppUser(
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
      metrimonyId: metrimonyId ?? this.metrimonyId,

      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,

      role: role ?? this.role,

      agentId: agentId ?? this.agentId,
      profileId: profileId ?? this.profileId,
      wishlists: wishlists ?? this.wishlists,

      phone: phone ?? this.phone,
    );
  }

  static AppUser empty() {
    return AppUser(
      isProfileCreated: false,
      metrimonyId: '',

      uid: '',

      fullName: '',
      email: '',
      role: '',
      phone: '',
      agentId: '',
      wishlists: [],
      profileId: '',
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
