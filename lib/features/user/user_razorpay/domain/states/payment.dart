import 'package:cloud_firestore/cloud_firestore.dart';

enum PayStatus {
  idle,
  loading,
  processing, // 👈 waiting for webhook
  success,
  failure,
}

class Payment {
  final String orderId; // internal order id
  final String razorpayOrderId; // Razorpay order id
  final String userId;
  final String email;
  final String phone;
  final String fullName;
  final String razorpayPaymentId;
  final String? razorpaySignature;
  final String agentId;
  final String region;
  final String district;
  final String gender;
  final int amount;
  final String status; // PENDING | SUCCESS | FAILED
  final String gateway;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String religion;
  final String caste;

  Payment({
    required this.razorpayPaymentId,

    this.razorpaySignature,
    required this.agentId,
    required this.region,
    required this.district,
    required this.gender,
    required this.religion,
    required this.caste,

    required this.orderId,
    required this.razorpayOrderId,
    required this.userId,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.amount,
    required this.status,
    this.gateway = 'razorpay',
    required this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      religion: map['religion'] ?? '',
      caste: map['caste'] ?? '',
      razorpayPaymentId: map['razorpayPaymentId'] ?? '',
      razorpaySignature: map['razorpaySignature'],
      agentId: map['agentId'],
      region: map['region'],
      district: map['district'],
      gender: map['gender'],

      orderId: map['orderId'] ?? '',
      razorpayOrderId: map['razorpayOrderId'] ?? '',
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      fullName: map['fullName'] ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? '',
      gateway: map['gateway'] ?? 'razorpay',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'religion': religion,
      'caste': caste,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'agentId': agentId,
      'region': region,
      'district': district,
      'gender': gender,
      'orderId': orderId,
      'razorpayOrderId': razorpayOrderId,
      'userId': userId,
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'amount': amount,
      'status': status,
      'gateway': gateway,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class PaymentState {
  final PayStatus status;
  final String? message;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? signature;
  final Payment? payment;
  const PaymentState({
    this.status = PayStatus.idle,
    this.message,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.signature,
    this.payment,
  });

  PaymentState copyWith({
    PayStatus? status,
    String? message,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? signature,
    Payment? payment,
  }) {
    return PaymentState(
      status: status ?? this.status,
      message: message ?? this.message,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      signature: signature ?? this.signature,
      payment: payment ?? this.payment,
    );
  }
}
