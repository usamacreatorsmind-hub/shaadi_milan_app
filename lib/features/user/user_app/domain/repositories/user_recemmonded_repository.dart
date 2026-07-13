import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/recemonded_profiles.dart';

class UserRecemmondedRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Fetch full recommended profile document
  Future<RecommendedProfiles> fetchRecommendedProfiles(String uid) async {
    try {
      debugPrint('Fetching recommended profiles for user: $uid');
      final DocumentSnapshot doc = await firestore
          .collection('suggested_profiles')
          .doc(uid)
          .get();

      debugPrint("these are  the recommended profiles data for user $uid:");
      debugPrint(doc.data().toString());

      if (doc.exists && doc.data() != null) {
        return RecommendedProfiles.fromJson(doc.data() as Map<String, dynamic>);
      }

      return RecommendedProfiles.empty();
    } catch (e) {
      debugPrint('Failed to fetch recommended profiles for $uid: $e');
      return RecommendedProfiles.empty();
    }
  }

  /// Fetch only ids list
  Future<List<String>> fetchRecommendedProfileIds(String uid) async {
    try {
      final profiles = await fetchRecommendedProfiles(uid);
      return profiles.ids;
    } catch (e) {
      debugPrint('Failed to fetch recommended profile IDs for $uid: $e');
      return const <String>[];
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
        'ids': FieldValue.arrayUnion(profileIds),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMutualRecommendedProfiles({
    required String sourceUid,
    required String sourceName,
    required String sourcePhone,
    required String sourceGender,
    required String targetUid,
    required String targetName,
    required String targetPhone,
    required String targetGender,
  }) async {
    try {
      final batch = firestore.batch();
      final sourceRef = firestore
          .collection('suggested_profiles')
          .doc(sourceUid);
      final targetRef = firestore
          .collection('suggested_profiles')
          .doc(targetUid);

      batch.set(sourceRef, {
        'userId': sourceUid,
        'name': sourceName,
        'phone': sourcePhone,
        'gender': sourceGender,
        'ids': FieldValue.arrayUnion([targetUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      batch.set(targetRef, {
        'userId': targetUid,
        'name': targetName,
        'phone': targetPhone,
        'gender': targetGender,
        'ids': FieldValue.arrayUnion([sourceUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeMutualRecommendedProfiles({
    required String sourceUid,
    required String targetUid,
  }) async {
    try {
      final batch = firestore.batch();
      final sourceRef = firestore
          .collection('suggested_profiles')
          .doc(sourceUid);
      final targetRef = firestore
          .collection('suggested_profiles')
          .doc(targetUid);

      batch.set(sourceRef, {
        'ids': FieldValue.arrayRemove([targetUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      batch.set(targetRef, {
        'ids': FieldValue.arrayRemove([sourceUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
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
