import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/states/payment.dart';

class PaymentFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Payment?> getUserPayment(String uid) async {
    try {
      final doc = await _firestore.collection('payments').doc(uid).get();

      if (!doc.exists) return null;

      return Payment.fromMap(doc.data()!);
    } catch (e) {
      print(e);                                                             
      throw Exception('Failed to get user payment: $e');
    }
  }
}
