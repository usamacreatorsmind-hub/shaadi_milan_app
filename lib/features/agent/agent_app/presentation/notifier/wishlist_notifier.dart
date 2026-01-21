import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../auth/domain/states/user_state.dart';
import '../../data/datasources/wishlist_firestore_ds.dart';
import '../../data/repositories_impl/wishlist_repository_impl.dart';
import '../../domain/repositories/wishlist_repository.dart';

/// ==========================================
/// Data Source Provider
/// ==========================================
final wishlistFirestoreDsProvider = Provider<WishlistFirestoreDS>((ref) {
  return WishlistFirestoreDSImpl();
});

/// ==========================================
/// Repository Provider
/// ==========================================
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final wishlistFirestoreDS = ref.watch(wishlistFirestoreDsProvider);
  return WishlistRepositoryImpl(wishlistFirestoreDS: wishlistFirestoreDS);
});

/// ==========================================
/// Wishlist State for Notifier
/// ==========================================
class WishlistListState {
  final List<WishlistEntity> wishlists;
  final bool isLoading;
  final String? error;
  final WishlistStatus? statusFilter;

  const WishlistListState({
    this.wishlists = const [],
    this.isLoading = false,
    this.error,
    this.statusFilter,
  });

  WishlistListState copyWith({
    List<WishlistEntity>? wishlists,
    bool? isLoading,
    String? error,
    WishlistStatus? statusFilter,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return WishlistListState(
      wishlists: wishlists ?? this.wishlists,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }

  List<WishlistEntity> get filteredWishlists {
    if (statusFilter == null) return wishlists;
    return wishlists.where((w) => w.status == statusFilter!.name).toList();
  }
}

/// ==========================================
/// Wishlist Notifier for Users (My Wishlist)
/// ==========================================
class MyWishlistNotifier extends StateNotifier<WishlistListState> {
  final WishlistRepository _repository;

  MyWishlistNotifier(this._repository) : super(const WishlistListState());

  Future<void> loadWishlists(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final wishlists = await _repository.getMyWishlists(userId);
      state = state.copyWith(wishlists: wishlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateStatus({
    required String wishlistId,
    required String status,
    required String updatedBy,
  }) async {
    try {
      await _repository.updateWishlistStatus(
        wishlistId: wishlistId,
        status: status,
        updatedBy: updatedBy,
      );
      // Update local state
      final updatedList = state.wishlists.map((w) {
        if (w.id == wishlistId) {
          return w.copyWith(status: status, updatedAt: DateTime.now());
        }
        return w;
      }).toList();
      state = state.copyWith(wishlists: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> addWishlist(WishlistEntity wishlist) async {
    try {
      final id = await _repository.addWishlist(wishlist);
      final newWishlist = wishlist.copyWith(id: id);
      state = state.copyWith(wishlists: [newWishlist, ...state.wishlists]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> removeWishlist(String wishlistId) async {
    try {
      await _repository.removeWishlist(wishlistId);
      final updatedList = state.wishlists.where((w) => w.id != wishlistId).toList();
      state = state.copyWith(wishlists: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void setStatusFilter(WishlistStatus? status) {
    if (status == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }
}

/// ==========================================
/// Wishlist Notifier for Users (Wishlisted Me)
/// ==========================================
class WishlistedMeNotifier extends StateNotifier<WishlistListState> {
  final WishlistRepository _repository;

  WishlistedMeNotifier(this._repository) : super(const WishlistListState());

  Future<void> loadWishlists(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final wishlists = await _repository.getWishlistedMe(userId);
      state = state.copyWith(wishlists: wishlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateStatus({
    required String wishlistId,
    required String status,
    required String updatedBy,
  }) async {
    try {
      await _repository.updateWishlistStatus(
        wishlistId: wishlistId,
        status: status,
        updatedBy: updatedBy,
      );
      // Update local state
      final updatedList = state.wishlists.map((w) {
        if (w.id == wishlistId) {
          return w.copyWith(status: status, updatedAt: DateTime.now());
        }
        return w;
      }).toList();
      state = state.copyWith(wishlists: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void setStatusFilter(WishlistStatus? status) {
    if (status == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }
}

/// ==========================================
/// Wishlist Notifier for Agents
/// ==========================================
class AgentWishlistNotifier extends StateNotifier<WishlistListState> {
  final WishlistRepository _repository;

  AgentWishlistNotifier(this._repository) : super(const WishlistListState());

  Future<void> loadWishlists(String agentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final wishlists = await _repository.getWishlistsForAgent(agentId);
      state = state.copyWith(wishlists: wishlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateStatus({
    required String wishlistId,
    required String status,
    required String updatedBy,
  }) async {
    try {
      await _repository.updateWishlistStatus(
        wishlistId: wishlistId,
        status: status,
        updatedBy: updatedBy,
      );
      // Update local state
      final updatedList = state.wishlists.map((w) {
        if (w.id == wishlistId) {
          return w.copyWith(status: status, updatedAt: DateTime.now());
        }
        return w;
      }).toList();
      state = state.copyWith(wishlists: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void setStatusFilter(WishlistStatus? status) {
    if (status == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }
}

/// ==========================================
/// Providers
/// ==========================================

/// Provider for My Wishlist (user is sender)
final myWishlistNotifierProvider =
    StateNotifierProvider<MyWishlistNotifier, WishlistListState>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return MyWishlistNotifier(repository);
});

/// Provider for Wishlisted Me (user is receiver)
final wishlistedMeNotifierProvider =
    StateNotifierProvider<WishlistedMeNotifier, WishlistListState>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return WishlistedMeNotifier(repository);
});

/// Provider for Agent Wishlists
final agentWishlistNotifierProvider =
    StateNotifierProvider<AgentWishlistNotifier, WishlistListState>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return AgentWishlistNotifier(repository);
});

/// ==========================================
/// Stream Providers for Real-time Updates
/// ==========================================

/// Stream provider for My Wishlist
final myWishlistStreamProvider =
    StreamProvider.family<List<WishlistEntity>, String>((ref, userId) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return repository.watchMyWishlists(userId);
});

/// Stream provider for Wishlisted Me
final wishlistedMeStreamProvider =
    StreamProvider.family<List<WishlistEntity>, String>((ref, userId) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return repository.watchWishlistedMe(userId);
});

/// Stream provider for Agent Wishlists
final agentWishlistStreamProvider =
    StreamProvider.family<List<WishlistEntity>, String>((ref, agentId) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return repository.watchWishlistsForAgent(agentId);
});

/// ==========================================
/// Helper Providers
/// ==========================================

/// Check if wishlist exists between sender and receiver
final existingWishlistProvider =
    FutureProvider.family<WishlistEntity?, ({String senderId, String receiverId})>(
        (ref, params) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return repository.getExistingWishlist(
    senderId: params.senderId,
    receiverId: params.receiverId,
  );
});

/// Get single wishlist by ID
final wishlistByIdProvider =
    FutureProvider.family<WishlistEntity?, String>((ref, wishlistId) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return repository.getWishlistById(wishlistId);
});
