import 'package:arvika_marriage_bureau/core/enums/enum.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../app/router/app_router.dart';
import '../../domain/states/metrimony_state.dart';
import '../controllers/metrimony_profile_controller.dart';
import 'user_address_form_screen.dart';
import 'user_biodata_check_screen.dart';
import 'user_culture_form_screen.dart';
import 'user_education_form_screen.dart';
import 'user_employement_form_screen.dart';
import 'user_family_form_screen.dart';
import 'user_identity_form_screen.dart';
import 'user_image_form_screen.dart';
import 'user_physical_form_screen.dart';

@RoutePage()
class MatrimonyFormFlowScreen extends ConsumerStatefulWidget {
  const MatrimonyFormFlowScreen({super.key});

  @override
  ConsumerState<MatrimonyFormFlowScreen> createState() =>
      _MatrimonyFormFlowScreenState();
}

class _MatrimonyFormFlowScreenState
    extends ConsumerState<MatrimonyFormFlowScreen> {
  final Map<MatrimonyStep, VoidCallback> _submitCallbacks = {};

  void _registerSubmit(MatrimonyStep step, VoidCallback callback) {
    _submitCallbacks[step] = callback;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metrimonyControllerProvider);
    final imageState = ref.watch(imagePickerProvider);

    ref.listen<MetrimonyState>(metrimonyControllerProvider, (prev, next) {
      if (next.isCompleted && prev?.isCompleted == false) {
        context.router.replaceAll([UserBiodataCheckRoute(isAgreed: false)]);
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Step ${MatrimonyStep.values.indexOf(state.step) + 1} / ${MatrimonyStep.values.length - 1}',

          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: IndexedStack(
              index: MatrimonyStep.values.indexOf(state.step),
              children: _buildSteps(state),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                children: [
                  // ⬅ PREVIOUS
                  if (state.step != MatrimonyStep.identity) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref
                              .read(metrimonyControllerProvider.notifier)
                              .previousStep();
                        },
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // ➡ NEXT
                  if (state.step != MatrimonyStep.user)
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // If a form has registered a submit callback, call it.
                          if (_submitCallbacks.containsKey(state.step)) {
                            _submitCallbacks[state.step]!.call();
                          } else if (state.step == MatrimonyStep.image) {
                            if (imageState.primaryImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select a primary profile image',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (imageState.aadharPdfPath == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select Aadhar PDF'),
                                ),
                              );
                              return;
                            }
                            ref
                                .read(metrimonyControllerProvider.notifier)
                                .nextStep();
                          } else {
                            // Fallback for screens without forms (e.g. Image upload if it handles itself or just next)
                            ref
                                .read(metrimonyControllerProvider.notifier)
                                .nextStep();
                          }
                        },
                        child: state.isLoading
                            ? const SizedBox(
                                height: 40,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Next'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSteps(MetrimonyState state) {
    return [
      UserIdentityFormScreen(
        mode: FormMode.create,
        existingIdentityProfile: state.metrimony.identity,
        registerSubmit: (cb) => _registerSubmit(MatrimonyStep.identity, cb),
      ),
      UserAddressFormScreen(
        mode: FormMode.create,
        existingAddressProfile: state.metrimony.address,
        registerSubmit: (cb) => _registerSubmit(MatrimonyStep.address, cb),
      ),
      UserEducationFormScreen(
        mode: FormMode.create,
        existingEducationProfile: state.metrimony.education,
        registerSubmit: (cb) => _registerSubmit(MatrimonyStep.education, cb),
        // Prevent popping, let controller handle next step
      ),
      UserEmploymentFormScreen(
        mode: FormMode.create,
        existingEmploymentProfile: state.metrimony.employment,
        registerSubmit: (cb) => _registerSubmit(MatrimonyStep.employment, cb),
      ),
      UserFamilyFormScreen(
        mode: FormMode.create,
        existingFamilyProfile: state.metrimony.family,
        registerSubmit: (cb) => _registerSubmit(MatrimonyStep.family, cb),
      ),
      UserCultureFormScreen(
        mode: FormMode.create,
        existingCulturalProfile: state.metrimony.cultural,
        registerSubmit: (cb) => _registerSubmit(MatrimonyStep.cultural, cb),
      ),
      UserPhysicalFormScreen(
        mode: FormMode.create,
        existingPhysicalProfile: state.metrimony.physical,
        registerSubmit: (cb) => _registerSubmit(MatrimonyStep.physical, cb),
      ),
      const UserImageFormScreen(),
      const UserBiodataCheckScreen(isAgreed: false),
    ];
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
