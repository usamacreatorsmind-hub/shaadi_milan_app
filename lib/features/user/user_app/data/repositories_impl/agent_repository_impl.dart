import 'package:arvika_marriage_bureau/features/agent/domain/states/agent_entity.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/repositories/agent_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return AgentRepositoryImpl(FirebaseFirestore.instance);
});

class AgentRepositoryImpl implements AgentRepository {
  final FirebaseFirestore _firestore;
  AgentRepositoryImpl(this._firestore);

  @override
  Future<AgentProfile> fetchAgent(String agentId) async {
    final doc = await _firestore
        .collection('agents')
        .where('agentId', isEqualTo: agentId)
        .limit(1)
        .get();

    if (doc.docs.isEmpty) {
      throw Exception('Agent with ID $agentId not found');
    }

    debugPrint(doc.docs.first.data().toString());
    return AgentProfile.fromMap(doc.docs.first.data());
  }
}
