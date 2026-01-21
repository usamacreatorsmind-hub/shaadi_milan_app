import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class WishlistFirestoreDS {
  /// Add a new wishlist entry to the 'wishlists' collection
  Future<String> addWishlist(WishlistEntity wishlist);

  /// Remove a wishlist by its document ID
  Future<void> removeWishlist(String wishlistId);

  /// Get all wishlists where the user is sender (My Wishlist)
  Future<List<WishlistEntity>> getMyWishlists(String userId);

  /// Get all wishlists where the user is receiver (Wishlisted Me)
  Future<List<WishlistEntity>> getWishlistedMe(String userId);

  /// Get all wishlists for an agent (both sender and receiver agent)
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

  /// Check if a wishlist already exists between sender and receiver
  Future<WishlistEntity?> getExistingWishlist({
    required String senderId,
    required String receiverId,
  });
}

class WishlistFirestoreDSImpl implements WishlistFirestoreDS {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _wishlistsCollection =>
      _firestore.collection('wishlists');

  @override
  Future<String> addWishlist(WishlistEntity wishlist) async {
    // Check if wishlist already exists
    final existing = await getExistingWishlist(
      senderId: wishlist.senderId,
      receiverId: wishlist.receiverId,
    );

    if (existing != null) {
      throw Exception('Wishlist already exists between these users');
    }

    final docRef = await _wishlistsCollection.add({
      'senderId': wishlist.senderId,
      'receiverId': wishlist.receiverId,
      'senderAgent': wishlist.senderAgent,
      'receiverAgent': wishlist.receiverAgent,
      'status': wishlist.status,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  @override
  Future<void> removeWishlist(String wishlistId) async {
    await _wishlistsCollection.doc(wishlistId).delete();
  }

  @override
  Future<List<WishlistEntity>> getMyWishlists(String userId) async {
    final querySnapshot = await _wishlistsCollection
        .where('senderId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return _mapToWishlistEntity(data);
    }).toList();
  }

  @override
  Future<List<WishlistEntity>> getWishlistedMe(String userId) async {
    final querySnapshot = await _wishlistsCollection
        .where('receiverId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return _mapToWishlistEntity(data);
    }).toList();
  }

  @override
  Future<List<WishlistEntity>> getWishlistsForAgent(String agentId) async {
    // Get wishlists where agent is either sender's agent or receiver's agent
    final senderAgentQuery = await _wishlistsCollection
        .where('senderAgent', isEqualTo: agentId)
        .get();

    final receiverAgentQuery = await _wishlistsCollection
        .where('receiverAgent', isEqualTo: agentId)
        .get();

    final Map<String, WishlistEntity> uniqueWishlists = {};

    for (final doc in senderAgentQuery.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      uniqueWishlists[doc.id] = _mapToWishlistEntity(data);
    }

    for (final doc in receiverAgentQuery.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      uniqueWishlists[doc.id] = _mapToWishlistEntity(data);
    }

    final wishlists = uniqueWishlists.values.toList();
    wishlists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return wishlists;
  }

  @override
  Future<void> updateWishlistStatus({
    required String wishlistId,
    required String status,
    required String updatedBy,
  }) async {
    await _wishlistsCollection.doc(wishlistId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
    });
  }

  @override
  Stream<List<WishlistEntity>> watchMyWishlists(String userId) {
    return _wishlistsCollection
        .where('senderId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return _mapToWishlistEntity(data);
            }).toList());
  }

  @override
  Stream<List<WishlistEntity>> watchWishlistedMe(String userId) {
    return _wishlistsCollection
        .where('receiverId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return _mapToWishlistEntity(data);
            }).toList());
  }

  @override
  Stream<List<WishlistEntity>> watchWishlistsForAgent(String agentId) {
    // Watch sender agent wishlists and combine with receiver agent
    final senderStream = _wishlistsCollection
        .where('senderAgent', isEqualTo: agentId)
        .snapshots();

    // Combine both streams
    return senderStream.asyncMap((senderSnapshot) async {
      final receiverSnapshot = await _wishlistsCollection
          .where('receiverAgent', isEqualTo: agentId)
          .get();

      final Map<String, WishlistEntity> uniqueWishlists = {};

      for (final doc in senderSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        uniqueWishlists[doc.id] = _mapToWishlistEntity(data);
      }

      for (final doc in receiverSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        uniqueWishlists[doc.id] = _mapToWishlistEntity(data);
      }

      final wishlists = uniqueWishlists.values.toList();
      wishlists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return wishlists;
    });
  }

  @override
  Future<WishlistEntity?> getWishlistById(String wishlistId) async {
    final doc = await _wishlistsCollection.doc(wishlistId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return _mapToWishlistEntity(data);
  }

  @override
  Future<WishlistEntity?> getExistingWishlist({
    required String senderId,
    required String receiverId,
  }) async {
    final querySnapshot = await _wishlistsCollection
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    final data = doc.data();
    data['id'] = doc.id;
    return _mapToWishlistEntity(data);
  }

  WishlistEntity _mapToWishlistEntity(Map<String, dynamic> data) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return WishlistEntity(
      id: data['id'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderAgent: data['senderAgent'] ?? '',
      receiverAgent: data['receiverAgent'] ?? '',
      status: data['status'] ?? WishlistStatus.pending.name,
      updatedAt: parseDateTime(data['updatedAt']),
    );
  }
}
