import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../states/amount.dart';
import '../states/payment_state.dart';

class PaymentRepository {
  final PaymentFirestore _paymentFirestore;
  PaymentRepository(this._paymentFirestore);

  Future<Map<String, dynamic>?> getUserPayment(String uid) async {
    return _paymentFirestore.getUserPayment(uid);
  }
}
