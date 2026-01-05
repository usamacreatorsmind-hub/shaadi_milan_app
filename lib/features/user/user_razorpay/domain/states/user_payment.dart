import 'package:cloud_firestore/cloud_firestore.dart';

class UserPayment {
  final String paymentId;
  final String orderId;
  final int amount;
  final String status;
  final DateTime createdAt;

  UserPayment({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory UserPayment.fromMap(Map<String, dynamic> map) {
    return UserPayment(
      paymentId: map['paymentId'],
      orderId: map['orderId'],
      amount: (map['amount'] as num).toInt(),
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

class UserPaymentState {
  final UserPayment? userPayment;
  final bool isLoading;
  final String? error;

  const UserPaymentState({
    this.userPayment,
    this.isLoading = false,
    this.error,
  });
  UserPaymentState copyWith({
    UserPayment? userPayment,
    bool? isLoading,
    String? error,
  }) {
    return UserPaymentState(
      userPayment: userPayment ?? this.userPayment,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const initial = UserPaymentState();
}
