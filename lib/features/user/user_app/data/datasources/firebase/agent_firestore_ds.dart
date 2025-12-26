import '../../../../../agent/domain/states/agent_entity.dart';
import '../../../domain/states/agent_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentFirestoreDsProvider = Provider<AgentFirestoreDs>((ref) {
  return AgentFirestoreDs(FirebaseFirestore.instance);
});

class AgentFirestoreDs {
  final FirebaseFirestore _firestore;
  AgentFirestoreDs(this._firestore);

  final String _collection = 'agents';

  Future<AgentProfile> fetchAgentbyAgentId(String agentId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('agentId', isEqualTo: agentId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Agent with ID $agentId not found');
    }
    print("this is agent data ");
    debugPrint(querySnapshot.docs.first.data().toString());

    if (querySnapshot.docs.first.data()['agentId'] != agentId) {
      throw Exception('Agent ID mismatch');
    }
    return AgentProfile.fromMap(querySnapshot.docs.first.data());
  }
}
