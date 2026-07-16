import '../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../core/enums/enum.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/user_physical_controllers.dart';
import '../../domain/states/physical_state.dart';

@RoutePage()
class UserPhysicalFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final PhysicalProfile? existingPhysicalProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserPhysicalFormScreen({
    super.key,
    required this.mode,
    required this.existingPhysicalProfile,
    this.registerSubmit,
  });

  @override
  ConsumerState<UserPhysicalFormScreen> createState() =>
      _UserPhysicalFormScreenState();
}

class _UserPhysicalFormScreenState
    extends ConsumerState<UserPhysicalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyTypeController = TextEditingController();
  final _complexionController = TextEditingController();
  final _disabilityDetailsController = TextEditingController();

  bool _physicallyChallenged = false;

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit &&
        widget.existingPhysicalProfile != null) {
      final profile = widget.existingPhysicalProfile!;
      _heightController.text = profile.height.toString();
      _weightController.text = profile.weight.toString();

      const bodyTypes = [
        'Slim',
        'Athletic',
        'Average',
        'Heavy',
        'Muscular',
        'Obese',
      ];
      final bodyTypeMatch = bodyTypes.where(
        (e) => e.toLowerCase() == profile.bodyType.toLowerCase(),
      );
      _bodyTypeController.text = bodyTypeMatch.isNotEmpty
          ? bodyTypeMatch.first
          : '';

      const complexions = [
        'Very Fair',
        'Fair',
        'Wheatish',
        'Dark',
        'Brown',
        'Duskey',
        'Dark Brown',
        'Black',
      ];
      final complexionMatch = complexions.where(
        (e) => e.toLowerCase() == profile.complexion.toLowerCase(),
      );
      _complexionController.text = complexionMatch.isNotEmpty
          ? complexionMatch.first
          : '';

      _physicallyChallenged = profile.physicallyChallenged;
      _disabilityDetailsController.text = profile.disabilityDetails ?? '';
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _bodyTypeController.dispose();
    _complexionController.dispose();
    _disabilityDetailsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(userPhysicalControllerProvider.notifier);

      if (widget.mode == FormMode.create) {
        notifier.savePhysicals(
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          bodyType: _bodyTypeController.text,
          complexion: _complexionController.text,
          physicallyChallenged: _physicallyChallenged,
          disabilityDetails: _physicallyChallenged
              ? _disabilityDetailsController.text
              : null,
        );
      } else {
        // Update logic (using savePhysicals as upsert)
        notifier.updatePhysicals(
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          bodyType: _bodyTypeController.text,
          complexion: _complexionController.text,
          physicallyChallenged: _physicallyChallenged,
          disabilityDetails: _physicallyChallenged
              ? _disabilityDetailsController.text
              : null,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final physicalState = ref.watch(userPhysicalControllerProvider);

    ref.listen<PhysicalState>(userPhysicalControllerProvider, (
      previous,
      current,
    ) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      } else if (current.physical != null && !physicalState.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLabels.physicalProfileSavedSuccessfully(context))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLabels.physicalDetails(context),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                controller: _heightController,
                prefixIcon: Icons.height,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.heightCm(context),
                hint: AppLabels.heightHint(context),
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? AppLabels.isRequired(context) : null,
              ),

              const SizedBox(height: 16),
              AppTextField(
                controller: _weightController,
                prefixIcon: Icons.monitor_weight,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.weightKg(context),
                hint: AppLabels.weightHint(context),
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? AppLabels.isRequired(context) : null,
              ),
              const SizedBox(height: 16),

              AppDropDown(
                label: AppLabels.selectBodyType(context),
                items: [
                  AppLabels.slim(context),
                  AppLabels.athletic(context),
                  AppLabels.average(context),
                  AppLabels.heavy(context),
                  AppLabels.muscular(context),
                  AppLabels.obese(context),
                ],

                value: _bodyTypeController.text.isEmpty
                    ? null
                    : _bodyTypeController.text,
                onChanged: (value) {
                  setState(() => _bodyTypeController.text = value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLabels.selectBodyType(context);
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              AppDropDown(
                label: AppLabels.selectComplexion(context),

                items: [
                  AppLabels.veryFair(context),
                  AppLabels.fair(context),
                  AppLabels.wheatish(context),
                  AppLabels.dark(context),
                  AppLabels.brown(context),
                  AppLabels.dusky(context),
                  AppLabels.darkBrown(context),
                  AppLabels.blackComplexion(context),
                ],

                value: _complexionController.text.isEmpty
                    ? null
                    : _complexionController.text,
                onChanged: (value) {
                  setState(() => _complexionController.text = value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLabels.selectComplexion(context);
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              AppSwitch(
                title: AppLabels.physicallyChallenged(context),
                value: _physicallyChallenged,
                onChanged: (value) {
                  setState(() {
                    _physicallyChallenged = value;
                  });
                },
              ),

              if (_physicallyChallenged) ...[
                const SizedBox(height: 16),
                AppTextField(
                  controller: _disabilityDetailsController,
                  prefixIcon: Icons.accessible,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: AppLabels.disabilityDetails(context),
                  hint: AppLabels.disabilityDetailsHint(context),
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  validator: (v) =>
                      v == null || v.isEmpty ? AppLabels.pleaseEnter(context) : null,
                ),
              ],

              const SizedBox(height: 20),
              if (physicalState.isLoading)
                const CircularProgressIndicator()
              else
                (widget.registerSubmit != null
                    ? const SizedBox.shrink()
                    : AppButton(
                        onPressed: _submitForm,
                        text: AppLabels.physicalProfile(context),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
