import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/global_providers.dart';
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
    BilingualValue? annualIncome,
    BilingualValue? workLocation,
    BilingualValue? districtEmployment,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final employmentProfile = EmploymentProfile(
      jobType: jobType,
      company: company,
      designation: designation,
      annualIncome: annualIncome,
      workLocation: workLocation,
      districtEmployment: districtEmployment,
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
    BilingualValue? annualIncome,
    BilingualValue? workLocation,
    BilingualValue? districtEmployment,
  }) {
    state = state.copyWith(isLoading: true, error: null);
    final employmentProfile = EmploymentProfile(
      jobType: jobType,
      company: company,
      designation: designation,
      annualIncome: annualIncome,
      workLocation: workLocation,
      districtEmployment: districtEmployment,
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
      final uid = ref.watch(targetUserIdProvider);
      return UserEmploymentController(matrimonyRepo, uid ?? '', ref);
    });

/// Provider to fetch designations from master_designations collection
final designationsProvider = FutureProvider<List<BilingualValue>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('master_designations')
      .orderBy('en')
      .get();

  return snapshot.docs.map((doc) {
    return BilingualValue.fromMap(doc.data());
  }).toList();
});

/// Provider to fetch annual incomes from master_annual_incomes collection
final annualIncomesProvider = FutureProvider<List<BilingualValue>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('master_annual_incomes')
      .orderBy('en') // You might want a specific sort order for income
      .get();

  return snapshot.docs.map((doc) {
    return BilingualValue.fromMap(doc.data());
  }).toList();
});
