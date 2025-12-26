class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? agentId;
  final String? profileId;
  final bool isVerified;
  final List<String>? wishlists;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.agentId,
    this.profileId,
    this.isVerified = false,
    this.wishlists,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'agentId': agentId,
      'profileId': profileId,
      'isVerified': isVerified,
      'wishlists': wishlists,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      phone: map['phone'] as String?,
      agentId: map['agentId'] as String?,
      profileId: map['profileId'] as String?,
      isVerified: map['isVerified'] as bool,

      wishlists: (map['wishlists'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, fullName: $fullName, wishlists: $wishlists, email: $email, role: $role, phone: $phone, agentId: $agentId, profileId: $profileId, isVerified: $isVerified)';
  }

  AppUser copyWith({
    String? uid,
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
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
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
      uid: '',
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
