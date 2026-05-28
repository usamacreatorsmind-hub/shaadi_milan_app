import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../auth/domain/states/agent_state.dart';
import '../../../../user/user_app/domain/states/metrimony_profile_view_model.dart';

abstract class MetrimonyFirestoreDs {
  Future<Map<String, dynamic>> getMetrimonyProfile(String userId);
  Future<MetrimonyProfileViewModel?> getMetrimonyProfileViewModel(String userId);
  Future<List<Map<String, dynamic>>> getAllMetrimonyProfiles();
  Stream<Map<String, dynamic>> watchMetrimonyProfile(String userId);
}

class MetrimonyFireStoreDsImpl implements MetrimonyFirestoreDs {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> getMetrimonyProfile(String userId) {
    return firestore.collection('metrimony_profiles').doc(userId).get().then((
      doc,
    ) {
      if (!doc.exists) {
        throw Exception('Metrimony profile not found for user: $userId');
      }
      return doc.data()!;
    });
  }

  @override
  Future<MetrimonyProfileViewModel?> getMetrimonyProfileViewModel(
    String userId,
  ) async {
    try {
      final matrimonyDoc = await firestore
          .collection('metrimony_profiles')
          .doc(userId)
          .get();

      if (!matrimonyDoc.exists) return null;

      final matrimonyData = matrimonyDoc.data()!;

      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      userData['uid'] = userId;

      AgentEntity? agentEntity;
      final agentId = matrimonyData['agentId'] as String?;

      if (agentId != null && agentId.isNotEmpty) {
        try {
          final agentDoc = await firestore
              .collection('agents')
              .doc(agentId)
              .get();
          if (agentDoc.exists) {
            final agentData = agentDoc.data()!;
            agentData['uid'] = agentId;
            agentEntity = AgentEntity.fromMap(agentData);
          }
        } catch (_) {
          agentEntity = null;
        }
      }

      return MetrimonyProfileViewModel.fromMap({
        'metrimonyProfile': matrimonyData,
        'userProfile': userData,
        'agentEntity': agentEntity?.toMap(),
      });
    } catch (e) {
      throw Exception('Failed to get matrimony profile view model: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMetrimonyProfiles() async {
    try {
      final querySnapshot = await firestore
          .collection('metrimony_profiles')
          .where('profileStatus', isEqualTo: 'active')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all matrimony profiles: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>> watchMetrimonyProfile(String userId) {
    return firestore
        .collection('metrimony_profiles')
        .doc(userId)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) {
          final data = doc.data()!;
          data['userId'] = userId;
          return data;
        });
  }
}
