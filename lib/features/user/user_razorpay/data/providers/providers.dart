// export data folder providers
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/amount_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/order_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/amount_firestore.dart';
export 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/order_firestore.dart';
export 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_firestore.dart';

final paymentFirestoreProvider = Provider<PaymentFirestore>((ref) {
  return PaymentFirestore();
});
final orderFirestoreProvider = Provider<OrderFirestore>((ref) {
  return OrderFirestore();
});

final amountFirestoreProvider = Provider<AmountFirestore>((ref) {
  return AmountFirestore();
}); 