import 'package:arvika_marriage_bureau/features/agent/domain/states/agent_entity.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/address_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/cultural_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/education_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/employee_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/family_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/identity_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/lifestyle_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/physical_state.dart';

/// matrimony_data_source.dart
 
 

abstract class MatrimonyDataSource {
  // ================= CREATE =================
  Future<void> createProfile(String uid, Map<String, dynamic> profileData);

  // ================= READ =================
  Future<MatrimonyProfile> getMatrimonyProfile(String uid);
  Stream<MatrimonyProfile> watchMatrimonyProfile(String uid);

  // ================= UPDATE (SECTION WISE) =================
  Future<void> updateIdentity(String uid, IdentityProfile identity);
  Future<void> updatePhysical(String uid, PhysicalProfile physical);
  Future<void> updateCultural(String uid, CulturalProfile cultural);
  Future<void> updateLifestyle(String uid, LifestyleProfile lifestyle);
  Future<void> updateEducation(String uid, EducationProfile education);
  Future<void> updateEmployment(String uid, EmploymentProfile employment);
  Future<void> updateFamily(String uid, FamilyProfile family);
  Future<void> updateAddress(String uid, AddressProfile address);
  Future<void> updateAgent(String uid, AgentProfile agent);

  Future<void> updateProfile(String uid, MatrimonyProfile profile);

  // ================= DELETE =================
  Future<void> deleteProfile(String uid);
}
