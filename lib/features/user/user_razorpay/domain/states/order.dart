import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId; // internal order id
  final String razorpayOrderId; // Razorpay order id

  final String userId;
  final String email;
  final String phone;
  final String fullName;
  final String razorpayPaymentId;
  final String? razorpaySignature;
  final String? agentId;
  final String? region;
  final String? district;
  final String? gender;

  final int amount;
  final String status; // PENDING | SUCCESS | FAILED
  final String gateway;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.orderId,
    required this.razorpayOrderId,

    required this.userId,
    required this.razorpayPaymentId,
    this.razorpaySignature,
    this.agentId,
    this.region,
    this.district,
    this.gender,

    required this.email,
    required this.phone,
    required this.fullName,
    required this.amount,
    required this.status,
    this.gateway = 'razorpay',
    required this.createdAt,
    this.updatedAt,
  });

  // ---------------- FIRESTORE ----------------
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      userId: map['userId'] ?? '',
      razorpayPaymentId: map['razorpayPaymentId'] ?? '',
      razorpaySignature: map['razorpaySignature'],
      agentId: map['agentId'],
      region: map['region'],
      district: map['district'],
      gender: map['gender'],

      orderId: map['orderId'] ?? '',
      razorpayOrderId: map['razorpayOrderId'] ?? '',

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
      'orderId': orderId,
      'razorpayOrderId': razorpayOrderId,
      'userId': userId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'agentId': agentId,
      'region': region,
      'district': district,
      'gender': gender,

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

class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({List<Order>? orders, bool? isLoading, String? error}) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const initial = OrderState();
}
