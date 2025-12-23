import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentFirestoreDsProvider = Provider<AgentFirestoreDs>((ref) {
  return AgentFirestoreDs(FirebaseFirestore.instance);
});

class AgentFirestoreDs {
  final FirebaseFirestore _firestore;
  AgentFirestoreDs(this._firestore);

  final String _collection = 'agents';

  Future<Map<String, dynamic>> fetchAgent(String agentId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('agentId', isEqualTo: agentId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Agent with ID $agentId not found');
    }

    return querySnapshot.docs.first.data();
  }
}
