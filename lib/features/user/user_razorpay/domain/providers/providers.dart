export 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/amount_repository.dart';
export 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/order_repository.dart';
export 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/payment_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/amount_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/order_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/providers/providers.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/amount_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/order_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/repository/payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(paymentFirestoreProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(orderFirestoreProvider));
});

final amountRepositoryProvider = Provider<AmountRepository>((ref) {
  return AmountRepository(amountFirestoreDS: ref.watch(amountFirestoreProvider));
});
