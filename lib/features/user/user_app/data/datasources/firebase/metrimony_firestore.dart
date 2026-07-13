import 'package:shadi_milan/core/constants/app_constants.dart';

import '../../../../../auth/domain/states/agent_state.dart';

import '../data_source/metrimony_data_source.dart';
import '../../../domain/states/address_state.dart';
import '../../../domain/states/cultural_state.dart';
import '../../../domain/states/education_state.dart';
import '../../../domain/states/employee_state.dart';
import '../../../domain/states/family_state.dart';
import '../../../domain/states/identity_state.dart';
import '../../../domain/states/metrimony_state.dart';
import '../../../domain/states/physical_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// provider

class MatrimonyFirestoreDS implements MatrimonyDataSource {
  final FirebaseFirestore _firestore;

  MatrimonyFirestoreDS(this._firestore);

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection(AppConstants.collProfiles);

  Future<void> _updateProfileSection(
    String uid,
    String key,
    dynamic data,
  ) async {
    await _profiles.doc(uid).update({
      key: data,
      AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> createProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    await _profiles.doc(uid).set(profileData, SetOptions(merge: true));
  }

  @override
  Future<MatrimonyProfile> getMatrimonyProfile(String uid) async {
    final doc = await _profiles.doc(uid).get();
    if (!doc.exists) {
      throw Exception('Matrimony profile not found');
    }
    return MatrimonyProfile.fromMap(doc.data()!);
  }

  @override
  Stream<MatrimonyProfile> watchMatrimonyProfile(String uid) {
    return _profiles.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Matrimony profile not found');
      }
      return MatrimonyProfile.fromMap(doc.data()!);
    });
  }

  @override
  Future<void> updateIdentity(String uid, IdentityProfile identity) async {
    await _updateProfileSection(uid, 'identity', identity.toMap());
  }

  @override
  Future<void> updatePhysical(String uid, PhysicalProfile physical) async {
    await _updateProfileSection(uid, 'physical', physical.toMap());
  }

  @override
  Future<void> updateCultural(String uid, CulturalProfile cultural) async {
    await _updateProfileSection(uid, 'cultural', cultural.toMap());
  }

  @override
  Future<void> updateEducation(String uid, EducationProfile education) async {
    await _updateProfileSection(uid, 'education', education.toMap());
  }

  @override
  Future<void> updateEmployment(
    String uid,
    EmploymentProfile employment,
  ) async {
    await _updateProfileSection(uid, 'employment', employment.toMap());
  }

  @override
  Future<void> updateFamily(String uid, FamilyProfile family) async {
    await _updateProfileSection(uid, 'family', family.toMap());
  }

  @override
  Future<void> updateAddress(String uid, AddressProfile address) async {
    await _updateProfileSection(uid, 'address', address.toMap());
  }

  Future<void> updateAgent(String uid, AgentEntity agent) async {
    await _updateProfileSection(uid, 'agent', agent.toMap());
  }

  @override
  Future<void> updateProfile(String uid, MatrimonyProfile profile) async {
    await _profiles.doc(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteProfile(String uid) async {
    await _profiles.doc(uid).delete();
  }

  @override
  Future<List<MatrimonyProfile>> getAllMatrimonyProfiles() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch only active profiles from metrimony_profiles collection
    final querySnapshot = await _profiles
        .where(AppConstants.fieldProfileStatus, isEqualTo: AppConstants.statusActive)
        .get();

    final profiles = querySnapshot.docs
        .map((doc) => MatrimonyProfile.fromMap(doc.data()))
        .toList();

    // Exclude current user's profile
    List<MatrimonyProfile> profileData = profiles
        .where((profile) => profile.userId != currentUid)
        .toList();

    // Get current user's gender
    final userDoc = await _firestore.collection(AppConstants.collUsers).doc(currentUid).get();

    final userGender = (userDoc.data()?[AppConstants.fieldGender] as String?)?.toLowerCase();

    if (userGender == null) return profileData;

    // Case-insensitive gender filter
    // if (userGender == 'male') {
    //   profileData = profileData
    //       .where((profile) => profile.identity.gender.toLowerCase() == 'female')
    //       .toList();
    // } else if (userGender == 'female') {
    //   profileData = profileData
    //       .where((profile) => profile.identity.gender.toLowerCase() == 'male')
    //       .toList();
    // }
    profileData = profileData
        // .where((profile) => profile.identity.gender.toLowerCase() == 'male')
        .toList();



    return profileData;
  }

  Stream<List<MatrimonyProfile>> watchAllMatrimonyProfiles() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return _profiles
        .where(
          AppConstants.fieldProfileStatus,
          isEqualTo: AppConstants.statusActive,
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MatrimonyProfile.fromMap(doc.data()))
              .where((profile) => profile.userId != currentUid)
              .toList();
        });
  }

  Stream<List<MatrimonyProfile>> watchMatrimonyProfilesForUsers(
    List<String> userIds,
  ) {
    if (userIds.isEmpty) {
      return Stream.value([]);
    }

    // Watch only active matrimony profiles and filter by userIds
    return _profiles
        .where(AppConstants.fieldProfileStatus, isEqualTo: AppConstants.statusActive)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => userIds.contains(doc.id))
              .map((doc) => MatrimonyProfile.fromMap(doc.data()))
              .toList();
        });
  }
}
