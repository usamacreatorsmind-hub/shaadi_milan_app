import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatus {
  final bool isProfileCreated;
  final bool isPaymentDone;
  final bool subscriptionActive;

  final String? paymentId;
  final DateTime? paymentAt;

  const UserStatus({
    this.isProfileCreated = false,
    this.isPaymentDone = false,
    this.subscriptionActive = false,
    this.paymentId,
    this.paymentAt,
  });

  // ---------------- FIRESTORE ----------------

  factory UserStatus.fromMap(Map<String, dynamic> map) {
    return UserStatus(
      isProfileCreated: map['isProfileCreated'] as bool? ?? false,
      isPaymentDone: map['isPaymentDone'] as bool? ?? false,
      subscriptionActive: map['subscriptionActive'] as bool? ?? false,
      paymentId: map['paymentId'] as String?,
      paymentAt: map['paymentAt'] != null
          ? (map['paymentAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isProfileCreated': isProfileCreated,
      'isPaymentDone': isPaymentDone,
      'subscriptionActive': subscriptionActive,
      'paymentId': paymentId,
      'paymentAt': paymentAt != null
          ? Timestamp.fromDate(paymentAt!)
          : null,
    };
  }

  @override
  String toString() {
    return 'UserStatus(profileCreated: $isProfileCreated, '
        'paymentDone: $isPaymentDone, '
        'subscriptionActive: $subscriptionActive)';
  }
}


class UserStatusState {
  final UserStatus userStatus;
  final bool isLoading;
  final String? error;

  const UserStatusState({
    this.userStatus = const UserStatus(),
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

  static const initial = UserStatusState();
}
