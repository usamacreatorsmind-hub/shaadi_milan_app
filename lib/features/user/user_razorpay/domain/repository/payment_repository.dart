import '../../data/firestore/payment_firestore.dart';
import '../states/payment.dart';

class PaymentRepository {
  final PaymentFirestore _paymentFirestore;
  PaymentRepository(this._paymentFirestore);

  /// Fetch payment data once (one-time fetch)
  Future<Payment?> getUserPayment(String uid) async {
    return _paymentFirestore.getUserPayment(uid);
  }

  /// Watch payment data in real-time (stream)
  Stream<Payment?> watchUserPayment(String uid) {
    return _paymentFirestore.watchUserPayment(uid);
  }
}
