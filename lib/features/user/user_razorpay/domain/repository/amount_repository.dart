import '../../data/firestore/amount_firestore.dart';
import '../states/amount.dart';

class AmountRepository {
  // ------------------  DEPENDENCIES ------------------
  final AmountFirestore _amountFirestoreDS;

  AmountRepository({required AmountFirestore amountFirestoreDS})
    : _amountFirestoreDS = amountFirestoreDS;

  // ------------------  METHODS ------------------

  Future<Amount> getAmount() async {
    try {
      return await _amountFirestoreDS.getAmount();
    } catch (e) {
      throw Exception('Failed to get amount: $e');
    }
  }
}
