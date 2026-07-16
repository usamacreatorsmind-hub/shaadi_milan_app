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
  final String paymentType;
  final String razorpayPaymentId;
  final String? razorpaySignature;
  final String agentId;
  final String region;
  final String district;
  final String gender;
  final int amount;
  final double agentCommission;
  final double commissionRate;
  final String agentDesignation;
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
    required this.paymentType,
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
    this.agentCommission = 0.0,
    this.commissionRate = 0.0,
    this.agentDesignation = '',
    required this.status,
    this.gateway = 'razorpay',
    required this.createdAt,
    this.updatedAt,
  });

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      religion: map['religion'] ?? '',
      caste: map['caste'] ?? '',
      razorpayPaymentId: map['razorpayPaymentId'] ?? '',

      paymentType: map['paymentType'] ?? '',
      razorpaySignature: map['razorpaySignature'],
      agentId: map['agentId'] ?? '',
      region: map['region'] ?? '',
      district: map['district'] ?? '',
      gender: map['gender'] ?? '',

      orderId: map['orderId'] ?? '',
      razorpayOrderId: map['razorpayOrderId'] ?? '',
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      fullName: map['fullName'] ?? '',
      amount: _parseAmount(map['amount']),
      agentCommission: (map['agentCommission'] ?? 0.0).toDouble(),
      commissionRate: (map['commissionRate'] ?? 0.0).toDouble(),
      agentDesignation: map['agentDesignation'] ?? '',
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
      'paymentType': paymentType,
      'orderId': orderId,
      'razorpayOrderId': razorpayOrderId,
      'userId': userId,
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'amount': amount,
      'agentCommission': agentCommission,
      'commissionRate': commissionRate,
      'agentDesignation': agentDesignation,
      'status': status,
      'gateway': gateway,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Payment copyWith({
    String? orderId,
    String? razorpayOrderId,
    String? userId,
    String? email,
    String? phone,
    String? fullName,
    String? paymentType,
    String? razorpayPaymentId,
    String? razorpaySignature,
    String? agentId,
    String? region,
    String? district,
    String? gender,
    int? amount,
    double? agentCommission,
    double? commissionRate,
    String? agentDesignation,
    String? status,
    String? gateway,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? religion,
    String? caste,
  }) {
    return Payment(
      orderId: orderId ?? this.orderId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      paymentType: paymentType ?? this.paymentType,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      agentId: agentId ?? this.agentId,
      region: region ?? this.region,
      district: district ?? this.district,
      gender: gender ?? this.gender,
      amount: amount ?? this.amount,
      agentCommission: agentCommission ?? this.agentCommission,
      commissionRate: commissionRate ?? this.commissionRate,
      agentDesignation: agentDesignation ?? this.agentDesignation,
      status: status ?? this.status,
      gateway: gateway ?? this.gateway,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
    );
  }
}

class PaymentState {
  final PayStatus status;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? signature;
  final Payment? payment;
  const PaymentState({
    this.status = PayStatus.idle,

    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.signature,
    this.payment,
  });

  PaymentState copyWith({
    PayStatus? status,

    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? signature,
    Payment? payment,
  }) {
    return PaymentState(
      status: status ?? this.status,

      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      signature: signature ?? this.signature,
      payment: payment ?? this.payment,
    );
  }

  factory PaymentState.initial() => const PaymentState(
    status: PayStatus.idle,
    razorpayPaymentId: null,
    razorpayOrderId: null,
    signature: null,
    payment: null,
  );
}
