import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatus {
  final bool isPaymentDone;
  final String uid;
  final String? paymentId;
  final DateTime? paymentAt;

  const UserStatus({
    required this.uid,

    required this.isPaymentDone,
    required this.paymentId,
    required this.paymentAt,
  });

  // ---------------- FIRESTORE ----------------

  factory UserStatus.fromMap(Map<String, dynamic> map) {
    return UserStatus(
      uid: map['uid'] as String? ?? '',

      isPaymentDone: map['isPaymentDone'] as bool? ?? false,
      paymentId: map['paymentId'] as String?,
      paymentAt: map['paymentAt'] != null
          ? (map['paymentAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,

      'isPaymentDone': isPaymentDone,
      'paymentId': paymentId,
      'paymentAt': paymentAt != null ? Timestamp.fromDate(paymentAt!) : null,
    };
  }

  @override
  String toString() {
    return 'UserStatus(paymentDone: $isPaymentDone, uid: $uid, paymentId: $paymentId, paymentAt: $paymentAt, ';
  }

  UserStatus copyWith({
    bool? isPaymentDone,
    String? uid,

    bool? subscriptionActive,
    String? paymentId,
    DateTime? paymentAt,
  }) {
    return UserStatus(
      uid: uid ?? this.uid,

      isPaymentDone: isPaymentDone ?? this.isPaymentDone,
      paymentId: paymentId ?? this.paymentId,
      paymentAt: paymentAt ?? this.paymentAt,
    );
  }

  const UserStatus.empty()
    : isPaymentDone = false,

      uid = '',
      paymentId = null,
      paymentAt = null;
}

class UserStatusState {
  final UserStatus userStatus;
  final bool isLoading;
  final String? error;

  const UserStatusState({
    this.userStatus = const UserStatus.empty(),
    this.isLoading = false,
    this.error,
  });

  UserStatusState copyWith({
    UserStatus? userStatus,
    bool? isLoading,
    String? error,
  }) {
    return UserStatusState(
      userStatus: userStatus ?? this.userStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const initial = UserStatusState(isLoading: true);
}
