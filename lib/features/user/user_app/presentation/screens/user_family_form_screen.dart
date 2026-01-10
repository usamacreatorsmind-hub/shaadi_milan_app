import '../../../../../app/custom/custom_widgets/widgets.dart';
import 'package:arvika_marriage_bureau/core/enums/enum.dart';

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
          const SnackBar(content: Text('Please select a family type')),
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
          const SnackBar(content: Text('Family profile saved successfully!')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Family Details',
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
                label: "Father's Name",
                hint: "Enter your father's name",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _motherNameController,
                prefixIcon: Icons.person,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Mother's Name",
                hint: "Enter your mother's name",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _brothersController,
                prefixIcon: Icons.people,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Number of Brothers",
                hint: "Enter number of brothers",
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _sistersController,
                prefixIcon: Icons.people_alt,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Number of Sisters",
                hint: "Enter number of sisters",
                obscureText: false,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              AppDropDown(
                label: "Family Type",
                items: const ['Joint Family', 'Nuclear Family'],
                value: _familyType,
                onChanged: (value) {
                  setState(() => _familyType = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a family type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // use dropdown
              AppDropDown(
                label: "LifeStyle Status",
                items: const [
                  'Prefer not to say',
                  'Simple Lifestyle',
                  'Moderate Lifestyle',
                  'Comfortable Lifestyle',
                  'Well-established Lifestyle',
                ],
                value: _familyStatusController.text.isEmpty
                    ? null
                    : _familyStatusController.text,
                onChanged: (value) {
                  setState(() => _familyStatusController.text = value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a family status';
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
                    : AppButton(onPressed: _submitForm, text: 'Save Family')),
            ],
          ),
        ),
      ),
    );
  }
}
