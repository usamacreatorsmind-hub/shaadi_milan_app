import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/order_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/user_payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderRepository {
  final OrderFirestore _orderFirestore;

  OrderRepository(this._orderFirestore);
  Future<List<Map<String, dynamic>>> getOrders(String uid) async {
    return _orderFirestore.getOrders(uid);
  }
}

final orderFirestoreProvider = Provider<OrderFirestore>((ref) {
  return OrderFirestore();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.read(orderFirestoreProvider));
});
