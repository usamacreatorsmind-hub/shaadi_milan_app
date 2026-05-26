import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../auth/domain/states/agent_state.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../../../user/user_app/data/datasources/firebase/agent_firestore_ds.dart';
import '../../../../user/user_razorpay/domain/states/payment.dart';
import '../../data/datasources/user_firestore.dart';
import '../../data/datasources/user_payments_ds.dart';
import '../../data/repositories_impl/user_payment_repository_impl.dart';
import '../../data/repositories_impl/user_repository_impl.dart';
import '../../domain/repositories/user_payments_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// ==========================================
/// Data Source Provider
/// ==========================================
final userFirestoreProvider = Provider<UserFirestore>((ref) {
  return UserFirestoreImpl();
});

/// ==========================================
/// Repository Provider
/// ==========================================
final agentUserRepositoryProvider = Provider<UserRepository>((ref) {
  final userFirestore = ref.watch(userFirestoreProvider);
  return UserRepositoryImpl(userFirestore: userFirestore);
});

/// ==========================================
/// Notifier for List of Users
/// ==========================================
class UsersNotifier extends StateNotifier<AsyncValue<List<UserEntity>>> {
  final UserRepository _userRepository;

  UsersNotifier(this._userRepository) : super(const AsyncValue.data([]));

  Future<void> getUsersForAgent() async {
    try {
      state = const AsyncValue.loading();
      final users = await _userRepository.getUsersForAgent();
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset users list
  void resetUsers() {
    state = const AsyncValue.data([]);
  }
}

/// Provider for UsersNotifier
final agentUsersNotifierProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<UserEntity>>>((ref) {
      final userRepository = ref.watch(agentUserRepositoryProvider);
      return UsersNotifier(userRepository);
    });

/// ==========================================
/// Notifier for Single User
/// ==========================================
class UserNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final UserRepository _userRepository;

  UserNotifier(this._userRepository) : super(const AsyncValue.data(null));

  /// Fetch a specific user by their UID
  Future<void> fetchUserById(String uid) async {
    try {
      state = const AsyncValue.loading();
      final user = await _userRepository.getUserById(uid);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update user in state
  void updateUser(UserEntity user) {
    state = AsyncValue.data(user);
  }

  /// Reset user
  void resetUser() {
    state = const AsyncValue.data(null);
  }

  Future<void> updateUserWishlistStatus({
    required String userId,
    required String profileId,
    required String status,
  }) async {
    state = const AsyncValue.loading();
    if (state.value == null) {
      await fetchUserById(userId);
    }
    UserEntity? currentUser = state.value;

    if (currentUser == null) {
      state = AsyncValue.error('User not found', StackTrace.current);
      return;
    }
  }

  Future<void> closeMatrimonyProfile(String userId) async {
    try {
      final currentUser = state.value;
      state = const AsyncValue.loading();
      await _userRepository.closeMatrimonyProfile(userId);

      // Update the local state if the operation was successful
      if (currentUser != null) {
        state = AsyncValue.data(currentUser.copyWith(profileStatus: 'closed'));
      } else {
        // Refetch the user if we didn't have their data
        await fetchUserById(userId);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}



/// Provider for UserNotifier
final agentUserNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserEntity?>>((ref) {
      final userRepository = ref.watch(agentUserRepositoryProvider);
      return UserNotifier(userRepository);
    });

/// Family provider to fetch user by ID (for wishlist items)
final wishlistUserProvider = FutureProvider.family<UserEntity?, String>((
  ref,
  userId,
) async {
  final userRepository = ref.watch(agentUserRepositoryProvider);
  return userRepository.getUserById(userId);
});

/// Family provider to fetch agent by agentId (for wishlist items)
final wishlistAgentProvider = FutureProvider.family<AgentEntity?, String>((
  ref,
  agentId,
) async {
  if (agentId.isEmpty) return null;
  try {
    final agentDs = ref.watch(agentFirestoreDsProvider);
    return await agentDs.fetchAgentbyAgentId(agentId);
  } catch (e) {
    return null;
  }
});

class UserPaymentNotifier extends StateNotifier<AsyncValue<Payment?>> {
  final UserPaymentsRepository _userPaymentsRepository;

  UserPaymentNotifier(this._userPaymentsRepository)
    : super(const AsyncValue.data(null));

  Future<void> getUserPayment({
    required String userId,
    required String agentId,
  }) async {
    try {
      state = const AsyncValue.loading();
      final payment = await _userPaymentsRepository.getUserPayment(
        userId: userId,
        agentId: agentId,
      );
      state = AsyncValue.data(payment);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final userPaymentDsProvider = Provider((ref) => UserpaymentsDSImpl());

final userPaymentsRepositoryProvider = Provider<UserPaymentsRepository>((ref) {
  return UserPaymentRepositoryImpl(ref.read(userPaymentDsProvider));
});

final userPaymentNotifierProvider =
    StateNotifierProvider<UserPaymentNotifier, AsyncValue<Payment?>>((ref) {
      return UserPaymentNotifier(ref.read(userPaymentsRepositoryProvider));
    });

class UsersPaymentsNotifier extends StateNotifier<AsyncValue<List<Payment?>>> {
  final UserPaymentsRepository _userPaymentsRepository;

  UsersPaymentsNotifier(this._userPaymentsRepository)
    : super(const AsyncValue.data([]));

  /// Fetch all payments for an agent
  Future<void> getUsersPayment({required String agentId}) async {
    try {
      state = const AsyncValue.loading();
      final payments = await _userPaymentsRepository.getUsersPayment(
        agentId: agentId,
      );
      // Filter out null values and keep valid payments
      final validPayments = payments.where((p) => p != null).toList();
      state = AsyncValue.data(validPayments);
    } catch (error, stackTrace) {
      print('Error fetching payments: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final usersPaymentsNotifierProvider =
    StateNotifierProvider<UsersPaymentsNotifier, AsyncValue<List<Payment?>>>((
      ref,
    ) {
      return UsersPaymentsNotifier(ref.read(userPaymentsRepositoryProvider));
    });

class AfterMarriagePaymentsNotifier
    extends StateNotifier<AsyncValue<List<Payment?>>> {
  final UserPaymentsRepository _userPaymentsRepository;

  AfterMarriagePaymentsNotifier(this._userPaymentsRepository)
    : super(const AsyncValue.data([]));

  /// Fetch all after marriage payments for an agent
  Future<void> getAfterMarriagePayments({required String agentId}) async {
    try {
      state = const AsyncValue.loading();
      final payments = await _userPaymentsRepository.getAfterMarriagePayments(
        agentId: agentId,
      );
      // Filter out null values and keep valid payments
      final validPayments = payments.where((p) => p != null).toList();
      state = AsyncValue.data(validPayments);
    } catch (error, stackTrace) {
      print('Error fetching after marriage payments: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final afterMarriagePaymentsNotifierProvider =
    StateNotifierProvider<
      AfterMarriagePaymentsNotifier,
      AsyncValue<List<Payment?>>
    >((ref) {
      return AfterMarriagePaymentsNotifier(
        ref.read(userPaymentsRepositoryProvider),
      );
    });

class AfterMarriagePaymentsForUserNotifier
    extends StateNotifier<AsyncValue<Payment?>> {
  final UserPaymentsRepository _userPaymentsRepository;

  AfterMarriagePaymentsForUserNotifier(this._userPaymentsRepository)
    : super(const AsyncValue.data(null));

  /// Fetch all after marriage payments for a specific user
  Future<void> getAfterMarriagePaymentForUser({required String userId}) async {
    try {
      state = const AsyncValue.loading();
      final payment = await _userPaymentsRepository
          .getAfterMarriagePaymentForUser(userId: userId);
      state = AsyncValue.data(payment);
    } catch (error, stackTrace) {
      print('Error fetching after marriage payments for user: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final afterMarriagePaymentsForUserNotifierProvider =
    StateNotifierProvider<
      AfterMarriagePaymentsForUserNotifier,
      AsyncValue<Payment?>
    >((ref) {
      return AfterMarriagePaymentsForUserNotifier(
        ref.read(userPaymentsRepositoryProvider),
      );
    });
