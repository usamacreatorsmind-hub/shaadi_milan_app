import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/order_firestore.dart';

class OrderRepository {
  final OrderFirestore _orderFirestore;

  OrderRepository(this._orderFirestore);

  Future<List<Map<String, dynamic>>> getPaymentHistory(String uid) async {
    return _orderFirestore.getOrders(uid);
  }
}
