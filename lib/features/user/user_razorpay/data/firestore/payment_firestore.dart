import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // read  payment for current user which only one payment
  Future<Map<String, dynamic>?> getUserPayment(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user payment: $e');
    }
  }

   
}
