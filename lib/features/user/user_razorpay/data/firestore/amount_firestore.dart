import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/states/amount.dart';

class AmountFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Amount> getAmount() async {
    try {
      final snap = await _firestore.collection('amounts').limit(1).get();

      final doc = snap.docs.first;

      if (!doc.exists) {
        throw Exception('Amount settings not found');
      }

      return Amount.fromMap(doc.data());
    } catch (e) {
      throw Exception('Failed to get amount: $e');
    }
  }
}
