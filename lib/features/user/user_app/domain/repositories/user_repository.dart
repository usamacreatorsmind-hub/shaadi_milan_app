import '../states/address_state.dart';
import '../states/user_state.dart';

abstract class UserRepository {
  Stream<AppUser> watchUser(String uid);
  Future<AppUser> fetchUser(String uid);
  Future<List<AppUser>> fetchUsers();
  
  Future<void> updateUser(String uid, AppUser user);
  Future<void> updateField(String uid, String fieldPath, dynamic value);
  Future<void> deleteUser(String uid);

  // Specific field updates
  Future<void> updateProfileId(String uid, String profileId);
  Future<void> updateAgentId(String uid, String agentId);
  Future<void> updatePhone(String uid, String phone);
  Future<void> updateRole(String uid, String role);
  Future<void> updateFullName(String uid, String fullName);
  Future<void> updateEmail(String uid, String email);
  Future<void> updatePassword(
    String uid,
    String password,
  ); // Note: Should be handled by FirebaseAuth
  Future<void> updateAddress(String uid, AddressProfile address);

  Future<void> updateProfilePhoto(String uid, String profilePhotoUrl);

  Future<void> addWishlist(String uid, String profileId);
  Future<void> removeWishlist(String uid, String profileId);

  // implement  method for user status 
  Future<void> updateUserStatus(String uid, UserStatus userStatus);
  Future<UserStatus> fetchUserStatus(String uid);
  Stream<UserStatus> watchUserStatus(String uid);
  
}
