import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/image_picker/image_picker_controller.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../../core/constants/app_labels.dart';
import '../../../../../core/enums/enum.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_translation_service.dart';
import '../../domain/states/image_state.dart';
import '../../domain/states/metrimony_state.dart';
import '../controllers/metrimony_profile_controller.dart';
import 'forms/user_address_form_screen.dart';
import 'forms/user_biodata_check_screen.dart';
import 'forms/user_culture_form_screen.dart';
import 'forms/user_education_form_screen.dart';
import 'forms/user_employement_form_screen.dart';
import 'forms/user_family_form_screen.dart';
import 'forms/user_identity_form_screen.dart';
import 'forms/user_image_form_screen.dart';
import 'forms/user_physical_form_screen.dart';

@RoutePage()
class MatrimonyFormFlowScreen extends ConsumerStatefulWidget {
  const MatrimonyFormFlowScreen({super.key});

  @override
  ConsumerState<MatrimonyFormFlowScreen> createState() => _MatrimonyFormFlowScreenState();
}

class _MatrimonyFormFlowScreenState extends ConsumerState<MatrimonyFormFlowScreen> {
  final Map<MatrimonyStep, VoidCallback> _submitCallbacks = {};

  void _registerSubmit(MatrimonyStep step, VoidCallback callback) {
    _submitCallbacks[step] = callback;
  }

  String? _validateImageStep(ImagesState imageState, BuildContext context) {
    if (imageState.profileImage == null || imageState.profileImage!.isEmpty) {
      return AppLocalizations.of(context)!.profileImageRequired;
    }
    if (imageState.primaryImage == null || imageState.primaryImage!.isEmpty) {
      return AppLocalizations.of(context)!.primaryImageRequired;
    }
    if (imageState.imageWithAgentUrl == null || imageState.imageWithAgentUrl!.isEmpty) {
      return AppLocalizations.of(context)!.imageWithAgentRequired;
    }
    if (imageState.secondaryImages.isEmpty) {
      return AppLocalizations.of(context)!.atLeastOneGalleryImageRequired;
    }
    if (imageState.aadharPdfPath == null || imageState.aadharPdfPath!.isEmpty) {
      return AppLocalizations.of(context)!.aadharDocumentRequired;
    }
    if (imageState.bioDataPath == null || imageState.bioDataPath!.isEmpty) {
      return "${AppLabels.uploadBioData(context)} ${AppLocalizations.of(context)!.isRequired}";
    }
    return null;
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
          '${AppLocalizations.of(context)!.step} ${MatrimonyStep.values.indexOf(state.step) + 1} / ${MatrimonyStep.values.length}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),

        actions: [
          // 🌐 Language Toggle Switch
          Consumer(
            builder: (context, ref, _) {
              final locale = ref.watch(localeProvider);
              final isHindi = locale.languageCode == 'hi';

              return Row(
                children: [
                  Text(
                    "EN",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isHindi ? FontWeight.normal : FontWeight.bold,
                      color: isHindi ? Colors.grey : Theme.of(context).primaryColor,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: isHindi,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) {
                        final code = val ? 'hi' : 'en';
                        ref.read(appTranslationServiceProvider).setLanguageCode(code);
                        ref.read(localeProvider.notifier).state = Locale(code);
                      },
                    ),
                  ),
                  Text(
                    "हि",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isHindi ? FontWeight.bold : FontWeight.normal,
                      color: isHindi ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: state.step == MatrimonyStep.user ? 0.0 : 80.0),
            child: IndexedStack(index: MatrimonyStep.values.indexOf(state.step), children: _buildSteps(state)),
          ),
          if (state.step != MatrimonyStep.user)
            Positioned(
              bottom: 20,
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
                            ref.read(metrimonyControllerProvider.notifier).previousStep();
                          },
                          child: Text(AppLabels.back(context)),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // ⏭ SKIP (Always enabled to make data filling non-mandatory)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(metrimonyControllerProvider.notifier).nextStep();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade800,
                          side: BorderSide(color: Colors.orange.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.skip_next_rounded, size: 20),
                        label: const Text("Skip", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ➡ NEXT
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // If a form has registered a submit callback, call it.
                          if (_submitCallbacks.containsKey(state.step)) {
                            _submitCallbacks[state.step]!.call();
                          } else {
                            // Fallback for screens without forms (e.g. Image upload handled by controller or just next)
                            ref.read(metrimonyControllerProvider.notifier).nextStep();
                          }
                        },
                        child: state.isLoading
                            ? const SizedBox(height: 40, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(AppLabels.next(context)),
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
      UserImageFormScreen(registerSubmit: (cb) => _registerSubmit(MatrimonyStep.image, cb)),

      const UserBiodataCheckScreen(isAgreed: false),
    ];
  }
}

enum MatrimonyStep { identity, address, education, employment, family, cultural, physical, image, user }
