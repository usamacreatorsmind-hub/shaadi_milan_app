class Amount {
  final int amount;
  final String currency;

  Amount({required this.amount, this.currency = "INR"});

  Map<String, dynamic> toMap() {
    return {'amount': amount, 'currency': currency};
  }

  factory Amount.fromMap(Map<String, dynamic> map) {
    return Amount(
      amount: map['amount'] as int,
      currency: map['currency'] as String,
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
