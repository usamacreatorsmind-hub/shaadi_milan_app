
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // read all orders from firstore for current user
  Future<List<Map<String, dynamic>>> getOrders(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }


}