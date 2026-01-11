import '../../data/firestore/payment_firestore.dart';
import '../states/payment.dart';

class PaymentRepository {
  final PaymentFirestore _paymentFirestore;
  PaymentRepository(this._paymentFirestore);

  Future<Payment?> getUserPayment(String uid) async {
    return _paymentFirestore.getUserPayment(uid);
  }
}
