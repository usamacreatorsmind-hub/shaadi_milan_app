class UserPaymentProfile {
  final String userId;
  final String paymentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String status; // e.g., 'pending', 'completed', 'failed'
  final String? transactionId;
  final DateTime? expiryDate; // For subscription-based payments

  UserPaymentProfile({
    required this.userId,
    required this.paymentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'paymentId': paymentId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  factory UserPaymentProfile.fromMap(Map<String, dynamic> map) {
    return UserPaymentProfile(
      userId: map['userId'] as String,
      paymentId: map['paymentId'] as String,
      amount: map['amount'] as double,
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      paymentMethod: map['paymentMethod'] as String,
      status: map['status'] as String,
      transactionId: map['transactionId'] as String?,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'] as String)
          : null,
    );
  }

  UserPaymentProfile copyWith({
    String? userId,
    String? paymentId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? status,
    String? transactionId,
    DateTime? expiryDate,
  }) {
    return UserPaymentProfile(
      userId: userId ?? this.userId,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  String toString() {
    return 'UserPaymentProfile(userId: $userId, paymentId: $paymentId, amount: $amount, paymentDate: $paymentDate, paymentMethod: $paymentMethod, status: $status, transactionId: $transactionId, expiryDate: $expiryDate)';
  }

  factory UserPaymentProfile.empty() {
    return UserPaymentProfile(
      userId: '',
      paymentId: '',
      amount: 0.0,
      paymentDate: DateTime.now(),
      paymentMethod: '',
      status: 'pending',
      transactionId: null,
      expiryDate: null,
    );
  }
}

class UserPaymentState {
  final UserPaymentProfile? payment;
  final bool isLoading;
  final String? error;

  const UserPaymentState({this.payment, this.isLoading = false, this.error});

  UserPaymentState copyWith({
    UserPaymentProfile? payment,
    bool? isLoading,
    String? error,
  }) {
    return UserPaymentState(
      payment: payment ?? this.payment,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = UserPaymentState(
    payment: null,
    isLoading: false,
    error: null,
  );
}
