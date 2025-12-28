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

  Future<String?> fetchAgentDocIdByAgentId(String agentId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('agentId', isEqualTo: agentId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      debugPrint('❌ Agent with ID $agentId not found');
      return null;
    }

    final docId = querySnapshot.docs.first.id;

    debugPrint('✅ Agent document ID: $docId');

    return docId;
  }

  // fetch agent doumetn using agent id
  Future<AgentProfile> fetchAgentProfilebyAgentId(String agentId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('agentId', isEqualTo: agentId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Agent with ID $agentId not found');
    }
    return AgentProfile.fromMap(querySnapshot.docs.first.data());
  }
}
