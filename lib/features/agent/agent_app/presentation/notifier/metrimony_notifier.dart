import '../../domain/repositories/user_payments_repository.dart';
import '../../../../user/user_app/domain/states/metrimony_state.dart';
import '../../../../user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/metrimony_firestore_ds.dart';
import '../../data/repositories_impl/metrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';

final metrimonyFirestoreDsProvider = Provider<MetrimonyFirestoreDs>((ref) {
  return MetrimonyFireStoreDsImpl();
});

final agentMetrimonyRepositoryProvider = Provider<MetrimonyRepository>((ref) {
  final metrimonyFirestoreDs = ref.watch(metrimonyFirestoreDsProvider);
  return MetrimonyRepositoryImpl(metrimonyFirestoreDs);
});

class AgentMetrimonyNotifier
    extends StateNotifier<AsyncValue<MatrimonyProfile?>> {
  final MetrimonyRepository _metrimonyRepository;

  AgentMetrimonyNotifier(this._metrimonyRepository)
    : super(const AsyncValue.data(null));

  Future<void> getMetrimonyProfile(String userId) async {
    try {
      state = const AsyncValue.loading();
      final profile = await _metrimonyRepository.getMetrimonyProfile(userId);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void resetProfile() {
    state = const AsyncValue.data(null);
  }
}

final agentMetrimonyNotifierProvider =
    StateNotifierProvider<
      AgentMetrimonyNotifier,
      AsyncValue<MatrimonyProfile?>
    >((ref) {
      final metrimonyRepository = ref.watch(agentMetrimonyRepositoryProvider);
      return AgentMetrimonyNotifier(metrimonyRepository);
    });

class MetrimonyNotifier extends StateNotifier<AsyncValue<MatrimonyProfile?>> {
  final MetrimonyRepository _metrimonyRepository;

  MetrimonyNotifier(this._metrimonyRepository)
    : super(const AsyncValue.data(null));

  Future<void> getUserPayment(String uid) async {
    final profile = await _metrimonyRepository.getMetrimonyProfile(uid);

    try {
      state = const AsyncValue.loading();

      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final matrimonyProfileViewModelProvider =
    FutureProvider.family<MetrimonyProfileViewModel?, String>((ref, userId) {
  final datasource = ref.watch(metrimonyFirestoreDsProvider);
  return datasource.getMetrimonyProfileViewModel(userId);
});
