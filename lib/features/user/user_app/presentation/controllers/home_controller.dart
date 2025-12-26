import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/metrimony_state.dart';

class HomeState {
  final AsyncValue<List<MatrimonyProfile>> metrimonyProfiles;

  const HomeState({this.metrimonyProfiles = const AsyncValue.loading()});

  HomeState copyWith({AsyncValue<List<MatrimonyProfile>>? metrimonyProfiles}) {
    return HomeState(
      metrimonyProfiles: metrimonyProfiles ?? this.metrimonyProfiles,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  final MatrimonyRepository _repository;

  HomeController(this._repository) : super(const HomeState()) {
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([_fetchPorfiles()]);
  }

  // fetch profile form server for details

  // GET MATRIMONY PROFILE FOR SPECIFIC USER
  Future<MatrimonyProfile> getMatrimonyProfile(String uid) async {
    return _repository.getMatrimonyProfile(uid);
  }

  Future<void> _fetchPorfiles() async {
    try {
      final profiles = await _repository.getAllMatrimonyProfiles();
      // print data to terminal one by one

      print(" Print fetched data to console");

      for (var profile in profiles) {
        print(profile.toString());
      }

      state = state.copyWith(metrimonyProfiles: AsyncValue.data(profiles));
    } catch (e, st) {
      state = state.copyWith(metrimonyProfiles: AsyncValue.error(e, st));
    }
  }
}

final userHomeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
      final repository = ref.watch(matrimonyRepositoryProvider);
      return HomeController(repository);
    });
