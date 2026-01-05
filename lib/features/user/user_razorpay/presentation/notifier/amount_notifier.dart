import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/amount_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/amount.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/amount_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AmountNotifier extends StateNotifier<AmountState> {
  final AmountRepository _amountRepository;

  AmountNotifier(this._amountRepository) : super(AmountState.initial) {
    fetchAmount();
  }

  Future<void> fetchAmount() async {
    // Set loading to true. We create a new state to ensure any previous error is cleared.
    state = AmountState(amount: state.amount, isLoading: true, error: null);

    try {
      final amount = await _amountRepository.getAmount();
      state = AmountState(amount: amount, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final amountFirestoreDSProvider = Provider<AmountFirestore>((ref) {
  return AmountFirestore();
});

final amountRepositoryProvider = Provider<AmountRepository>((ref) {
  return AmountRepository(
    amountFirestoreDS: ref.watch(amountFirestoreDSProvider),
  );
});

final amountNotifierProvider =
    StateNotifierProvider<AmountNotifier, AmountState>((ref) {
      return AmountNotifier(ref.watch(amountRepositoryProvider));
    });
