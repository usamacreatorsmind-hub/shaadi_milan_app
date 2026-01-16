import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentApiFirestore {
  // fetch credentials from firestore

  Future<String?> getUrl() async {
    final doc = await FirebaseFirestore.instance
        .collection('paymentCredentials')
        .doc('url')
        .get();

    if (!doc.exists) return null;

    print(doc.data()?['payment_url']);
    return doc.data()?['payment_url'];
  }
}
// export provider

final paymentApiFirestoreProvider = Provider<PaymentApiFirestore>((ref) {
  return PaymentApiFirestore();
});
