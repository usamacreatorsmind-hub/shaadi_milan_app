import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserPaymentDs {
  Future<Payment?> getUserPayment({
    required String userId,
    required String agentId,
  });
  Future<List<Payment?>> getUsersPayment();
}

class UserpaymentsDSImpl implements UserPaymentDs {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<Payment?> getUserPayment({
    required String userId,
    required String agentId,
  }) async {
    try {
      // match field value
      final querySnapshot = await firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .where('agentId', isEqualTo: agentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No payment found for this user and agent
      }
      final doc = querySnapshot.docs.first;

      return Payment.fromMap(doc.data()!);
    } catch (e) {
      print(e);
      throw Exception('Failed to get user payment: $e');
    }
  }

  @override
  Future<List<Payment?>> getUsersPayment() async {
    try {
      final querySnapshot = await firestore.collection('payments').get();
      return querySnapshot.docs.map((doc) {
        if (!doc.exists) return null;
        return Payment.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print(e);
      throw Exception('Failed to get users payments: $e');
    }
  }
}
