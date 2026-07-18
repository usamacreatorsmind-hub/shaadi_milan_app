import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../domain/states/employee_state.dart';
import 'metrimony_profile_controller.dart';

class UserEmploymentController extends StateNotifier<EmploymentState> {
  final MatrimonyRepository _matrimonyRepository;
  final String _uid;
  final Ref _ref;

  UserEmploymentController(this._matrimonyRepository, this._uid, this._ref)
    : super(EmploymentState.initial);

  Future<void> saveEmployment({
    required BilingualValue jobType,
    BilingualValue? company,
    BilingualValue? designation,
    int? annualIncome,
    BilingualValue? workLocation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final employmentProfile = EmploymentProfile(
      jobType: jobType,
      company: company,
      designation: designation,
      annualIncome: annualIncome,
      workLocation: workLocation,
    );

    try {
      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveEmployment(employmentProfile);

      state = state.copyWith(employment: employmentProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateEmployment({
    required BilingualValue jobType,
    BilingualValue? company,
    BilingualValue? designation,
    int? annualIncome,
    BilingualValue? workLocation,
  }) {
    state = state.copyWith(isLoading: true, error: null);
    final employmentProfile = EmploymentProfile(
      jobType: jobType,
      company: company,
      designation: designation,
      annualIncome: annualIncome,
      workLocation: workLocation,
    );

    try {
      _ref
          .read(matrimonyRepositoryProvider)
          .updateEmploymentProfile(_uid, employmentProfile);

      state = state.copyWith(employment: employmentProfile, isLoading: false);
      _ref
          .read(metrimonyControllerProvider.notifier)
          .saveEmployment(employmentProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userEmploymentControllerProvider =
    StateNotifierProvider.autoDispose<
      UserEmploymentController,
      EmploymentState
    >((ref) {
      final matrimonyRepo = ref.read(matrimonyRepositoryProvider);
      final authState = ref.read(authStateProvider);
      final uid = authState.value?.fold((agent) => null, (user) => user.uid);
      if (uid == null) throw Exception('User not authenticated');
      return UserEmploymentController(matrimonyRepo, uid, ref);
    });
