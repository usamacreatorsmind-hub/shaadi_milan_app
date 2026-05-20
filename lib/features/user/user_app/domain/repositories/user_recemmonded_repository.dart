import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/recemonded_profiles.dart';

class UserRecemmondedRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Fetch full recommended profile document
  Future<RecommendedProfiles> fetchRecommendedProfiles(String uid) async {
    try {
      print('Fetching recommended profiles for user: $uid');
      final DocumentSnapshot doc = await firestore
          .collection('suggested_profiles')
          .doc(uid)
          .get();

      print("these are  the recommended profiles data for user $uid:");
      print(doc.data());

      if (doc.exists && doc.data() != null) {
        return RecommendedProfiles.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('No recommended profiles found for user $uid');
      }
    } catch (e) {
      throw Exception('Failed to fetch recommended profiles: $e');
    }
  }

  /// Fetch only ids list
  Future<List<String>> fetchRecommendedProfileIds(String uid) async {
    try {
      final profiles = await fetchRecommendedProfiles(uid);

      return profiles.ids;
    } catch (e) {
      throw Exception('Failed to fetch recommended profile IDs: $e');
    }
  }

  /// Update recommended profiles for a user
  Future<bool> updateRecommendedProfiles({
    required String uid,
    required String name,
    required String phone,
    required String gender,
    required List<String> profileIds,
  }) async {
    try {
      await firestore.collection('suggested_profiles').doc(uid).set({
        'userId': uid,
        'name': name,
        'phone': phone,
        'gender': gender,
        'ids': profileIds,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }
}

final userRecemmondedRepositoryProvider = Provider<UserRecemmondedRepository>((
  ref,
) {
  return UserRecemmondedRepository();
});

final recommendedProfilesProvider =
    FutureProvider.family<RecommendedProfiles, String>((ref, uid) async {
      final repository = ref.watch(userRecemmondedRepositoryProvider);
      return repository.fetchRecommendedProfiles(uid);
    });

final recommendedIdsProvider = FutureProvider.family<List<String>, String>((
  ref,
  uid,
) async {
  final repository = ref.watch(userRecemmondedRepositoryProvider);
  return repository.fetchRecommendedProfileIds(uid);
});

final currentUserRecommendedIdsProvider = FutureProvider<List<String>>((
  ref,
) async {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null || currentUid.isEmpty) {
    return const <String>[];
  }

  final repository = ref.watch(userRecemmondedRepositoryProvider);
  return repository.fetchRecommendedProfileIds(currentUid);
});
