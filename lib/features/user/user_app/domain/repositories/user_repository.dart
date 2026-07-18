import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';

import '../../../../auth/domain/states/user_state.dart';
import '../states/address_state.dart';

abstract class UserRepository {
  Stream<UserEntity> watchUser(String uid);
  Future<UserEntity> fetchUser(String uid);
  Future<List<UserEntity>> fetchUsers();
  Stream<List<UserEntity>> watchOppositeGenderUsers(String currentUid);

  Future<void> updateUser(String uid, UserEntity user);
  Future<void> updateField(String uid, String fieldPath, dynamic value);
  Future<void> deleteUser(String uid);

  // Specific field updates
  Future<void> updateProfileId(String uid, String profileId);
  Future<void> updateAgentId(String uid, String agentId);
  Future<void> updatePhone(String uid, String phone);
  Future<void> updateRole(String uid, String role);
  Future<void> updateFullName(String uid, BilingualValue fullName);
  Future<void> updateEmail(String uid, String email);
  Future<void> updatePassword(
    String uid,
    String password,
  ); // Note: Should be handled by FirebaseAuth
  Future<void> updateAddress(String uid, AddressProfile address);

  Future<void> updateProfilePhoto(String uid, String profilePhotoUrl);
  

  
}
