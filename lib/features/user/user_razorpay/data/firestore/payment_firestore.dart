import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/states/payment.dart';

class PaymentFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch payment data once (one-time fetch)
  Future<Payment?> getUserPayment(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _firestore
          .collection('registrationPayment')
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return Payment.fromMap(doc.data()!);
    } catch (e) {
      print(e);
      throw Exception('Failed to get user payment: $e');
    }
  }

  /// Watch payment data in real-time (stream)
  Stream<Payment?> watchUserPayment(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore
        .collection('registrationPayment')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }
          return Payment.fromMap(snapshot.data()!);
        });
  }

  // create empty payment document
  Future<void> createEmptyPayment({
    required Payment initialPaymentData,
    required String uid,
  }) async {
    try {
      final data = initialPaymentData.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('registrationPayment').doc(uid).set(data);
    } catch (e) {
      throw Exception('Failed to create empty payment: $e');
    }
  }

  Future<Payment?> fetchUserPostMarriagePayment(String uid) async {
    try {
      final doc = await _firestore
          .collection('afterMarriagePayment')
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return Payment.fromMap(doc.data()!);
    } catch (e) {
      print(e);
      throw Exception('Failed to get user post marriage payment: $e');
    }
  }
}
