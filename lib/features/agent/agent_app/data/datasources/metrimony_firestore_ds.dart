import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../auth/domain/states/agent_state.dart';
import '../../../../user/user_app/domain/states/metrimony_profile_view_model.dart';

abstract class MetrimonyFirestoreDs {
  Future<Map<String, dynamic>> getMetrimonyProfile(String userId);
  Future<MetrimonyProfileViewModel> getMetrimonyProfileViewModel(String userId);
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
  Future<MetrimonyProfileViewModel> getMetrimonyProfileViewModel(
    String userId,
  ) async {
    try {
      // Fetch matrimony profile
      final matrimonyDoc = await firestore
          .collection('metrimony_profiles')
          .doc(userId)
          .get();

      if (!matrimonyDoc.exists) {
        throw Exception('Matrimony profile not found for user: $userId');
      }

      final matrimonyData = matrimonyDoc.data()!;

      // Fetch user profile
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User profile not found for user: $userId');
      }

      final userData = userDoc.data()!;
      userData['uid'] = userId; // Add uid to user data

      // Fetch agent profile if agentId exists
      AgentEntity? agentEntity;
      final agentId = matrimonyData['agentId'] as String?;

      if (agentId != null && agentId.isNotEmpty) {
        try {
          final agentDoc = await firestore.collection('agents').doc(agentId).get();
          if (agentDoc.exists) {
            final agentData = agentDoc.data()!;
            agentData['uid'] = agentId; // Add uid to agent data
            agentEntity = AgentEntity.fromMap(agentData);
          }
        } catch (e) {
          // Agent not found, continue without agent data
          agentEntity = null;
        }
      }

      // Create view model
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
      // Fetch only active profiles from metrimony_profiles collection
      final querySnapshot = await firestore
          .collection('metrimony_profiles')
          .where('profileStatus', isEqualTo: 'active')
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['userId'] = doc.id; // Ensure userId is set
            return data;
          })
          .toList();
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
        .map((doc) {
      if (!doc.exists) {
        throw Exception('Matrimony profile not found for user: $userId');
      }
      final data = doc.data()!;
      data['userId'] = userId;
      return data;
    });
  }
}
