enum MatrimonyPaymentType {
  registration, // Before marriage (searching, matching)
  afterMarriage, // After marriage (couple profile)
}

class Amount {
  final int amount;
  final String paymentType;
  final String currency;

  Amount({
    required this.amount,
    required this.paymentType,

    this.currency = "INR",
  });

  Map<String, dynamic> toMap() {
    return {'amount': amount, 'currency': currency};
  }

  factory Amount.fromMap(Map<String, dynamic> map) {
    return Amount(
      paymentType: map['paymentType'] as String,

      amount: map['amount'] as int,
      currency: map['currency'] as String,
    );
  }

  @override
  String toString() {
    return 'Amount(amount: $amount, paymentType: $paymentType, currency: $currency)';
  }

  // copy
  Amount copyWith({int? amount, String? paymentType, String? currency}) {
    return Amount(
      amount: amount ?? this.amount,
      paymentType: paymentType ?? this.paymentType,
      currency: currency ?? this.currency,
    );
  }
}

class AmountState {
  final Amount? amount;
  final bool isLoading;
  final String? error;

  const AmountState({this.amount, this.isLoading = false, this.error});

  AmountState copyWith({Amount? amount, bool? isLoading, String? error}) {
    return AmountState(
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static const initial = AmountState(
    amount: null,
    isLoading: false,
    error: null,
  );
}
