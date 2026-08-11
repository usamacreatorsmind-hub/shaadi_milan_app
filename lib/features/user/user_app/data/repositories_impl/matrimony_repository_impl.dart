import '../../../../auth/domain/states/agent_state.dart';
import '../../domain/states/address_state.dart';
import '../../domain/states/cultural_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/states/education_state.dart';
import '../../domain/states/employee_state.dart';
import '../../domain/states/family_state.dart';
import '../../domain/states/identity_state.dart';
import '../../domain/states/metrimony_state.dart';
import '../../domain/states/physical_state.dart';
import '../datasources/firebase/metrimony_firestore.dart';
import '../../domain/repositories/metrimony_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatrimonyRepositoryImpl implements MatrimonyRepository {
  final MatrimonyFirestoreDS _remoteDS;

  MatrimonyRepositoryImpl(this._remoteDS);

  @override
  Future<void> createMatrimonyProfile(String uid, Map<String, dynamic> profileData) async {
    await _remoteDS.createProfile(uid, profileData);
  }

  @override
  Future<void> deleteMatrimonyProfile(String uid) async {
    await _remoteDS.deleteProfile(uid);
  }

  @override
  Future<MatrimonyProfile> getMatrimonyProfile(String uid) {
    return _remoteDS.getMatrimonyProfile(uid);
  }

  @override
  Stream<MatrimonyProfile> watchMatrimonyProfile(String uid) {
    return _remoteDS.watchMatrimonyProfile(uid);
  }

  @override
  Stream<List<MatrimonyProfile>> watchMatrimonyProfilesForUsers(List<String> userIds) {
    return _remoteDS.watchMatrimonyProfilesForUsers(userIds);
  }

  @override
  Future<void> updateAddressProfile(String uid, AddressProfile address) {
    return _remoteDS.updateAddress(uid, address);
  }

  @override
  Future<void> updateCulturalProfile(String uid, CulturalProfile cultural) {
    return _remoteDS.updateCultural(uid, cultural);
  }

  @override
  Future<void> updateEducationProfile(String uid, EducationProfile education) {
    return _remoteDS.updateEducation(uid, education);
  }

  @override
  Future<void> updateEmploymentProfile(String uid, EmploymentProfile employment) {
    return _remoteDS.updateEmployment(uid, employment);
  }

  @override
  Future<void> updateFamilyProfile(String uid, FamilyProfile family) {
    return _remoteDS.updateFamily(uid, family);
  }

  @override
  Future<void> updateIdentityProfile(String uid, IdentityProfile identity) {
    return _remoteDS.updateIdentity(uid, identity);
  }

  @override
  Future<void> updatePhysicalProfile(String uid, PhysicalProfile physical) {
    return _remoteDS.updatePhysical(uid, physical);
  }

  @override
  Future<void> updateMatrimonyProfile(String uid, MatrimonyProfile profile) {
    return _remoteDS.updateProfile(uid, profile);
  }

  @override
  Future<void> updateAgentEntity(String uid, AgentEntity agent) {
    return _remoteDS.updateAgent(uid, agent);
  }

  // ---------------- Get Single Sections ----------------

  @override
  Future<AddressProfile> getAddressProfile(String uid) async => (await getMatrimonyProfile(uid)).address;

  @override
  Future<CulturalProfile> getCulturalProfile(String uid) async => (await getMatrimonyProfile(uid)).cultural;

  @override
  Future<EducationProfile> getEducationProfile(String uid) async => (await getMatrimonyProfile(uid)).education;

  @override
  Future<EmploymentProfile> getEmploymentProfile(String uid) async => (await getMatrimonyProfile(uid)).employment;

  @override
  Future<FamilyProfile> getFamilyProfile(String uid) async => (await getMatrimonyProfile(uid)).family;

  @override
  Future<IdentityProfile> getIdentityProfile(String uid) async => (await getMatrimonyProfile(uid)).identity;

  @override
  Future<PhysicalProfile> getPhysicalProfile(String uid) async => (await getMatrimonyProfile(uid)).physical;

  @override
  Future<List<MatrimonyProfile>> getAllMatrimonyProfiles() {
    return _remoteDS.getAllMatrimonyProfiles();
  }

  @override
  Stream<List<MatrimonyProfile>> watchAllMatrimonyProfiles() {
    return _remoteDS.watchAllMatrimonyProfiles();
  }
}

final matrimonyFirestoreDSProvider = Provider<MatrimonyFirestoreDS>((ref) {
  return MatrimonyFirestoreDS(FirebaseFirestore.instance);
});

final matrimonyRepositoryProvider = Provider<MatrimonyRepository>((ref) {
  final remoteDS = ref.read(matrimonyFirestoreDSProvider);
  return MatrimonyRepositoryImpl(remoteDS);
});
