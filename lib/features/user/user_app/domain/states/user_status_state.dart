class UserStatus {
  final String uid;

  final bool isProfileCreated;
  final bool isApproved;
  final bool isRejected;

  UserStatus({
    required this.uid,

    this.isProfileCreated = false,

    this.isApproved = false,
    this.isRejected = false,
  });
  UserStatus copyWith({
    String? uid,
    bool? isProfileCreated,
    bool? isApproved,
    bool? isRejected,
  }) {
    return UserStatus(
      uid: uid ?? this.uid,
      isProfileCreated: isProfileCreated ?? this.isProfileCreated,
      isApproved: isApproved ?? this.isApproved,
      isRejected: isRejected ?? this.isRejected,
    );
  }

  // implem a named constructor that return true for all
  UserStatus.all(String id)
    : uid = id,

      isProfileCreated = true,

      isApproved = false,
      isRejected = false;

  // implem a named constructor that return true for all
  UserStatus.approved(String id)
    : uid = id,

      isProfileCreated = true,

      isApproved = true,
      isRejected = false;

  // implem a named constructor that return true for all
  UserStatus.rejected(String id)
    : uid = id,
      isProfileCreated = true,

      isApproved = false,
      isRejected = true;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,

      'isProfileCreated': isProfileCreated,

      'isApproved': isApproved,
      'isRejected': isRejected,
    };
  }

  factory UserStatus.fromMap(Map<String, dynamic> map) {
    return UserStatus(
      uid: map['uid'] as String? ?? '',
      isProfileCreated: map['isProfileCreated'] as bool? ?? false,
      isApproved: map['isApproved'] as bool? ?? false,
      isRejected: map['isRejected'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'UserStatus(uid: $uid, isProfileCreated: $isProfileCreated, isApproved: $isApproved, isRejected: $isRejected)';
  }

  static UserStatus empty({required String id}) {
    return UserStatus(
      uid: id,

      isProfileCreated: false,

      isApproved: false,
      isRejected: false,
    );
  }
}
