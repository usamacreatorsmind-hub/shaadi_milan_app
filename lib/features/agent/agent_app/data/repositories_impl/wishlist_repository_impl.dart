import '../../../../auth/domain/states/user_state.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_firestore_ds.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistFirestoreDS _wishlistFirestoreDS;

  WishlistRepositoryImpl({required WishlistFirestoreDS wishlistFirestoreDS})
      : _wishlistFirestoreDS = wishlistFirestoreDS;

  @override
  Future<String> addWishlist(WishlistEntity wishlist) {
    return _wishlistFirestoreDS.addWishlist(wishlist);
  }

  @override
  Future<void> removeWishlist(String wishlistId) {
    return _wishlistFirestoreDS.removeWishlist(wishlistId);
  }

  @override
  Future<List<WishlistEntity>> getMyWishlists(String userId) {
    return _wishlistFirestoreDS.getMyWishlists(userId);
  }

  @override
  Future<List<WishlistEntity>> getWishlistedMe(String userId) {
    return _wishlistFirestoreDS.getWishlistedMe(userId);
  }

  @override
  Future<List<WishlistEntity>> getWishlistsForAgent(String agentId) {
    return _wishlistFirestoreDS.getWishlistsForAgent(agentId);
  }

  @override
  Future<void> updateWishlistStatus({
    required String wishlistId,
    required String status,
    required String updatedBy,
  }) {
    return _wishlistFirestoreDS.updateWishlistStatus(
      wishlistId: wishlistId,
      status: status,
      updatedBy: updatedBy,
    );
  }

  @override
  Stream<List<WishlistEntity>> watchMyWishlists(String userId) {
    return _wishlistFirestoreDS.watchMyWishlists(userId);
  }

  @override
  Stream<List<WishlistEntity>> watchWishlistedMe(String userId) {
    return _wishlistFirestoreDS.watchWishlistedMe(userId);
  }

  @override
  Stream<List<WishlistEntity>> watchWishlistsForAgent(String agentId) {
    return _wishlistFirestoreDS.watchWishlistsForAgent(agentId);
  }

  @override
  Future<WishlistEntity?> getWishlistById(String wishlistId) {
    return _wishlistFirestoreDS.getWishlistById(wishlistId);
  }

  @override
  Future<WishlistEntity?> getExistingWishlist({
    required String senderId,
    required String receiverId,
  }) {
    return _wishlistFirestoreDS.getExistingWishlist(
      senderId: senderId,
      receiverId: receiverId,
    );
  }
}
