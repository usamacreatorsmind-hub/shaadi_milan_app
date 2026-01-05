import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;            // internal order id
  final String razorpayOrderId;    // Razorpay order id
  final String? paymentId;

  final String uid;
  final String email;
  final String phone;
  final String fullName;

  final int amount;
  final String currency;
  final String status; // PENDING | SUCCESS | FAILED
  final String paymentGateway;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.orderId,
    required this.razorpayOrderId,
    this.paymentId,
    required this.uid,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    this.paymentGateway = 'razorpay',
    required this.createdAt,
    this.updatedAt,
  });

  // ---------------- FIRESTORE ----------------
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'],
      razorpayOrderId: map['razorpayOrderId'],
      paymentId: map['paymentId'],
      uid: map['uid'],
      email: map['email'],
      phone: map['phone'],
      fullName: map['fullName'],
      amount: (map['amount'] as num).toInt(),
      currency: map['currency'] ?? 'INR',
      status: map['status'],
      paymentGateway: map['paymentGateway'] ?? 'razorpay',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'razorpayOrderId': razorpayOrderId,
      'paymentId': paymentId,
      'uid': uid,
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentGateway': paymentGateway,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
