import '../../../../auth/domain/states/user_state.dart';

abstract class WishlistRepository {
  /// Add a new wishlist
  Future<String> addWishlist(WishlistEntity wishlist);

  /// Remove a wishlist
  Future<void> removeWishlist(String wishlistId);

  /// Get wishlists where user is sender (My Wishlist)
  Future<List<WishlistEntity>> getMyWishlists(String userId);

  /// Get wishlists where user is receiver (Wishlisted Me)
  Future<List<WishlistEntity>> getWishlistedMe(String userId);

  /// Get all wishlists for an agent
  Future<List<WishlistEntity>> getWishlistsForAgent(String agentId);

  /// Update wishlist status - accessible by all 4 roles
  Future<void> updateWishlistStatus({
    required String wishlistId,
    required String status,
    required String updatedBy,
  });

  /// Stream wishlists where user is sender
  Stream<List<WishlistEntity>> watchMyWishlists(String userId);

  /// Stream wishlists where user is receiver
  Stream<List<WishlistEntity>> watchWishlistedMe(String userId);

  /// Stream wishlists for agent
  Stream<List<WishlistEntity>> watchWishlistsForAgent(String agentId);

  /// Get a single wishlist by ID
  Future<WishlistEntity?> getWishlistById(String wishlistId);

  /// Check if wishlist exists between sender and receiver
  Future<WishlistEntity?> getExistingWishlist({
    required String senderId,
    required String receiverId,
  });
}
