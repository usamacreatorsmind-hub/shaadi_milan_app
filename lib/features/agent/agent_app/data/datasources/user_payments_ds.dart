import '../../../../user/user_razorpay/domain/states/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserPaymentDs {
  Future<Payment?> getUserPayment({
    required String userId,
    required String agentId,
  });
  Future<List<Payment?>> getUsersPayment({required String agentId});
}

class UserpaymentsDSImpl implements UserPaymentDs {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<Payment?> getUserPayment({
    required String userId,
    required String agentId,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection('registrationPayment')
          .where('userId', isEqualTo: userId)
          .where('agentId', isEqualTo: agentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return Payment.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      print('Error fetching user payment: $e');
      throw Exception('Failed to get user payment: $e');
    }
  }

  @override
  Future<List<Payment?>> getUsersPayment({required String agentId}) async {
    try {
      print('Fetching payments for agent: $agentId');

      final querySnapshot = await firestore
          .collection('registrationPayment')
          .where('agentId', isEqualTo: agentId)
          .get();

      print('Found ${querySnapshot.docs.length} payments for agent $agentId');

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final payments = querySnapshot.docs.map((doc) {
        try {
          return Payment.fromMap(doc.data());
        } catch (e) {
          print('Error parsing payment document ${doc.id}: $e');
          return null;
        }
      }).toList();

      return payments;
    } catch (e) {
      print('Error fetching users payments: $e');
      throw Exception('Failed to get users payments: $e');
    }
  }
}
