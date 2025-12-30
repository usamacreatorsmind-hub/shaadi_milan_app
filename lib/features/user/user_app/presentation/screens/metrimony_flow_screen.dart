import '../../../../../app/router/app_router.dart';
import '../../domain/states/metrimony_state.dart';
import '../controllers/metrimony_profile_controller.dart';
import 'agent_profile_verify_screen.dart';
import 'user_address_form_screen.dart';
import 'user_culture_form_screen.dart';
import 'user_biodata_check_screen.dart';
import 'user_education_form_screen.dart';
import 'user_employement_form_screen.dart';
import 'user_family_form_screen.dart';
import 'user_home_screen.dart';
import 'user_identity_form_screen.dart';
import 'user_image_form_screen.dart';
import 'user_physical_form_screen.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class MatrimonyFormFlowScreen extends ConsumerWidget {
  const MatrimonyFormFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(metrimonyControllerProvider);

    ref.listen<MetrimonyState>(metrimonyControllerProvider, (prev, next) {
      if (next.isCompleted && prev?.isCompleted == false) {
        context.router.replaceAll([UserBiodataCheckRoute(isAgreed: false)]);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Step ${MatrimonyStep.values.indexOf(state.step) + 1} / ${MatrimonyStep.values.length - 1}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              ref.read(metrimonyControllerProvider.notifier).previousStep(),
        ),
      ),
      body: _buildStep(state.step),
    );
  }

  Widget _buildStep(MatrimonyStep step) {
    switch (step) {
      case MatrimonyStep.identity:
        return const UserIdentityFormScreen();

      case MatrimonyStep.address:
        return const UserAddressFormScreen();
      case MatrimonyStep.education:
        return const UserEducationFormScreen();

      case MatrimonyStep.employment:
        return const UserEmploymentFormScreen();

      case MatrimonyStep.family:
        return const UserFamilyFormScreen();

      case MatrimonyStep.cultural:
        return const UserCultureFormScreen();
      case MatrimonyStep.physical:
        return const UserPhysicalFormScreen();
      case MatrimonyStep.image:
        return const UserImageFormScreen();

      case MatrimonyStep.user:
        return const UserBiodataCheckScreen(isAgreed: false);
    }
  }
}

enum MatrimonyStep {
  identity,
  address,
  education,
  employment,
  family,
  cultural,
  physical,
  image,
  user,
}
