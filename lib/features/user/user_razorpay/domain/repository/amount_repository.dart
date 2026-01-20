import '../../data/firestore/amount_firestore.dart';
import '../states/amount.dart';

class AmountRepository {
  // ------------------  DEPENDENCIES ------------------
  final AmountFirestore _amountFirestoreDS;

  AmountRepository({required AmountFirestore amountFirestoreDS})
    : _amountFirestoreDS = amountFirestoreDS;

  // ------------------  METHODS ------------------

  Future<Amount> getRegistrationAmount() async {
    try {
      return await _amountFirestoreDS.getRegistrationAmount();
    } catch (e) {
      throw Exception('Failed to get amount: $e');
    }
  }

  Future<Amount> getPostMarriageAmountforMale() async {
    try {
      return await _amountFirestoreDS.getPostMarriageAmountforMale();
    } catch (e) {
      throw Exception('Failed to get amount: $e');
    }
  }

  Future<Amount> getPostMarriageAmountforFemale() async {
    try {
      return await _amountFirestoreDS.getPostMarriageAmountforFemale();
    } catch (e) {
      throw Exception('Failed to get amount: $e');
    }
  }         

}
