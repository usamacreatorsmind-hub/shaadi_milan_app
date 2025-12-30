import '../states/agent_state.dart';

import '../../../../agent/domain/states/agent_entity.dart';
import '../states/address_state.dart';
import '../states/cultural_state.dart';
import '../states/education_state.dart';
import '../states/employee_state.dart';
import '../states/family_state.dart';
import '../states/identity_state.dart'; 
import '../states/metrimony_state.dart';
import '../states/physical_state.dart';

import '../../../../agent/domain/states/agent_entity.dart';

enum EnumUserStatus { active, inactive, blocked, pending }

abstract class MatrimonyRepository {
  // ─────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────
  Future<void> createMatrimonyProfile(
    String uid,
    Map<String, dynamic> profileData,
  );

  // ─────────────────────────────────────────────
  // READ (FULL PROFILE)
  // ─────────────────────────────────────────────
  Future<MatrimonyProfile> getMatrimonyProfile(String uid);

  // read stream all metrimony profiles from server
  Future<List<MatrimonyProfile>> getAllMatrimonyProfiles();

  Stream<MatrimonyProfile> watchMatrimonyProfile(String uid);

  // ─────────────────────────────────────────────
  // UPDATE (SECTION-WISE)
  // ─────────────────────────────────────────────
  Future<void> updateIdentityProfile(String uid, IdentityProfile identity);

  Future<void> updatePhysicalProfile(String uid, PhysicalProfile physical);

  Future<void> updateCulturalProfile(String uid, CulturalProfile cultural);
 

  Future<void> updateEducationProfile(String uid, EducationProfile education);

  Future<void> updateEmploymentProfile(
    String uid,
    EmploymentProfile employment,
  );

  Future<void> updateFamilyProfile(String uid, FamilyProfile family);

  Future<void> updateAddressProfile(String uid, AddressProfile address);

  Future<void> updateAgentProfile(String uid, AgentProfile agent);

  Future<void> updateMatrimonyProfile(String uid, MatrimonyProfile profile);

  // ─────────────────────────────────────────────
  // READ (SECTION-WISE)
  // ─────────────────────────────────────────────
  Future<IdentityProfile> getIdentityProfile(String uid);
  Future<PhysicalProfile> getPhysicalProfile(String uid);
  Future<CulturalProfile> getCulturalProfile(String uid); 
  Future<EducationProfile> getEducationProfile(String uid);
  Future<EmploymentProfile> getEmploymentProfile(String uid);
  Future<FamilyProfile> getFamilyProfile(String uid);
  Future<AddressProfile> getAddressProfile(String uid);
  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  Future<void> deleteMatrimonyProfile(String uid);
}
