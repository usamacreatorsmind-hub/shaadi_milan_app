import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/states/amount.dart';

class AmountFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Amount> getRegistrationAmount() async {
    try {
      final snap = await _firestore
          .collection('amounts')
          .doc('registration')
          .get();

      if (!snap.exists) {
        throw Exception('Amount settings not found');
      }

      final data = snap.data();
      if (data == null) {
        throw Exception('Amount data is empty');
      }
      return Amount.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get amount: $e');
    }
  }

  Future<Amount> getPostMarriageAmountforMale() async {
    final snap = await _firestore
        .collection('amounts')
        .doc('afterMarriageAmountforMale')
        .get();

    if (!snap.exists) {
      throw Exception('Amount settings not found');
    }

    final data = snap.data();
    if (data == null) {
      throw Exception('Amount data is empty');
    }
    return Amount.fromMap(data);
  }

  Future<Amount> getPostMarriageAmountforFemale() async {
    try {
      final snap = await _firestore
          .collection('amounts')
          .doc('afterMarriageAmountforFemale')
          .get();

      if (!snap.exists) {
        throw Exception('Amount settings not found');
      }

      final data = snap.data();
      if (data == null) {
        throw Exception('Amount data is empty');
      }
      return Amount.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get amount: $e');
    }
  }
}
