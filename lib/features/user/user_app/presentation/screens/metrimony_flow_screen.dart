import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/metrimony_profile_controller.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/agent_profile_verify_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_address_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_culture_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_biodata_check_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_education_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_employement_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_family_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_home_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_identity_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_image_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_lifestyle_form_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_physical_form_screen.dart';
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
          'Step ${MatrimonyStep.values.indexOf(state.step)} / ${MatrimonyStep.values.length - 1}',
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
      case MatrimonyStep.lifestyle:
        return const UserLifestyleFormScreen();
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
  lifestyle,
  physical,
  image,
  user,
}
