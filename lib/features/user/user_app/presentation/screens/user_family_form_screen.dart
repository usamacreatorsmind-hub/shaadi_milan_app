import '../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../core/enums/enum.dart';

import '../../domain/states/family_state.dart';
import '../controllers/user_family_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_route/auto_route.dart';

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
      _fatherNameController.text = profile.fatherName;
      _motherNameController.text = profile.motherName;
      _brothersController.text = profile.numberOfBrothers.toString();
      _sistersController.text = profile.numberOfSisters.toString();
      _familyType = profile.familyType;
      _familyStatusController.text = profile.familyStatus;
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
          fatherName: _fatherNameController.text,
          motherName: _motherNameController.text,
          brothers: int.parse(_brothersController.text),
          sisters: int.parse(_sistersController.text),
          familyType: _familyType!,
          familyStatus: _familyStatusController.text,
        );
      } else {
        // Update logic (using saveFamily as upsert)
        notifier.updateFamily(
          fatherName: _fatherNameController.text,
          motherName: _motherNameController.text,
          brothers: int.parse(_brothersController.text),
          sisters: int.parse(_sistersController.text),
          familyType: _familyType!,
          familyStatus: _familyStatusController.text,
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
          SnackBar(content: Text(AppLabels.familyProfileSavedSuccessfully(context))),
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
              AppTextField(
                controller: _fatherNameController,
                prefixIcon: Icons.person,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.fatherName(context),
                hint: AppLabels.fatherNameHint(context),
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _motherNameController,
                prefixIcon: Icons.person,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.motherName(context),
                hint: AppLabels.motherNameHint(context),
                obscureText: false,
                keyboardType: TextInputType.text,
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

              AppDropDown(
                label: AppLabels.familyType(context),
                items: [AppLabels.jointFamily(context), AppLabels.nuclearFamily(context)],
                value: _familyType,
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
              AppDropDown(
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
                    : AppButton(onPressed: _submitForm, text: AppLabels.saveFamily(context))),
            ],
          ),
        ),
      ),
    );
  }
}
