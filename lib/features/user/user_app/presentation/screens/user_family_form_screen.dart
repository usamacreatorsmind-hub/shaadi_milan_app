import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../core/constants/app_labels.dart';
import '../../../../../core/enums/enum.dart';
import '../../../../translitration/widgets/bilingual_text_field.dart';
import '../../domain/states/family_state.dart';
import '../controllers/user_family_controllers.dart';

@RoutePage()
class UserFamilyFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final FamilyProfile? existingFamilyProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserFamilyFormScreen({
    super.key,
    required this.mode,
    required this.existingFamilyProfile,
    this.registerSubmit,
  });

  @override
  ConsumerState<UserFamilyFormScreen> createState() =>
      _UserFamilyFormScreenState();
}

class _UserFamilyFormScreenState extends ConsumerState<UserFamilyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _brothersController = TextEditingController();
  final _familyStatusController = TextEditingController();

  final _sistersController = TextEditingController();

  String? _familyType;

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit && widget.existingFamilyProfile != null) {
      final profile = widget.existingFamilyProfile!;
      _fatherNameController.text = profile.fatherName.en;
      _motherNameController.text = profile.motherName.en;
      _brothersController.text = profile.numberOfBrothers.toString();
      _sistersController.text = profile.numberOfSisters.toString();
      _familyType = profile.familyType.en;
      _familyStatusController.text = profile.familyStatus.en;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_familyType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLabels.selectFamilyType(context))),
        );
        return;
      }

      final notifier = ref.read(userFamilyControllerProvider.notifier);

      if (widget.mode == FormMode.create) {
        notifier.saveFamily(
          fatherName: BilingualValue(hi: _fatherNameController.text, en: _fatherNameController.text),
          motherName: BilingualValue(hi: _motherNameController.text, en: _motherNameController.text),
          brothers: int.parse(_brothersController.text),
          sisters: int.parse(_sistersController.text),
          familyType: BilingualValue(hi: _familyType!, en: _familyType!),
          familyStatus: BilingualValue(hi: _familyStatusController.text, en: _familyStatusController.text),
        );
      } else {
        // Update logic (using saveFamily as upsert)
        notifier.updateFamily(
          fatherName: BilingualValue(hi: _fatherNameController.text, en: _fatherNameController.text),
          motherName: BilingualValue(hi: _motherNameController.text, en: _motherNameController.text),
          brothers: int.parse(_brothersController.text),
          sisters: int.parse(_sistersController.text),
          familyType: BilingualValue(hi: _familyType!, en: _familyType!),
          familyStatus: BilingualValue(hi: _familyStatusController.text, en: _familyStatusController.text),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(userFamilyControllerProvider);

    ref.listen<FamilyState>(userFamilyControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      } else if (current.family != null && previous?.family == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLabels.familyProfileSavedSuccessfully(context)),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLabels.familyDetails(context),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BilingualTextField(
                controller: _fatherNameController,
                prefixIcon: Icons.person,
                label: AppLabels.fatherName(context),
                hint: AppLabels.fatherNameHint(context),
                validator: (v) => v == null || v.isEmpty
                    ? AppLabels.isRequired(context)
                    : null,
              ),
              const SizedBox(height: 16),
              BilingualTextField(
                controller: _motherNameController,
                prefixIcon: Icons.person,
                label: AppLabels.motherName(context),
                hint: AppLabels.motherNameHint(context),
                validator: (v) => v == null || v.isEmpty
                    ? AppLabels.isRequired(context)
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _brothersController,
                prefixIcon: Icons.people,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.numberOfBrothers(context),
                hint: AppLabels.brothersHint(context),
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _sistersController,
                prefixIcon: Icons.people_alt,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.numberOfSisters(context),
                hint: AppLabels.sistersHint(context),
                obscureText: false,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              AppDropDown<String>(
                label: AppLabels.familyType(context),
                items: [
                  AppLabels.jointFamily(context),
                  AppLabels.nuclearFamily(context),
                ],
                value: _familyType,
                itemLabel: (type) => type,
                onChanged: (value) {
                  setState(() => _familyType = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLabels.selectFamilyType(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // use dropdown
              AppDropDown<String>(
                label: AppLabels.lifeStyleStatus(context),
                items: [
                  AppLabels.preferNotToSay(context),
                  AppLabels.simpleLifestyle(context),
                  AppLabels.moderateLifestyle(context),
                  AppLabels.comfortableLifestyle(context),
                  AppLabels.wellEstablishedLifestyle(context),
                ],
                value: _familyStatusController.text.isEmpty
                    ? null
                    : _familyStatusController.text,
                itemLabel: (status) => status,
                onChanged: (value) {
                  setState(() => _familyStatusController.text = value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLabels.selectLifeStyleStatus(context);
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              if (familyState.isLoading)
                const CircularProgressIndicator()
              else
                (widget.registerSubmit != null
                    ? const SizedBox.shrink()
                    : AppButton(
                        onPressed: _submitForm,
                        text: AppLabels.saveFamily(context),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
