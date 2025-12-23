import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';

import '../../domain/states/family_state.dart';
import '../controllers/user_family_controllers.dart';
import '../providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_route/auto_route.dart';

@RoutePage()
class UserFamilyFormScreen extends ConsumerStatefulWidget {
  const UserFamilyFormScreen({super.key});

  @override
  ConsumerState<UserFamilyFormScreen> createState() =>
      _UserFamilyFormScreenState();
}

class _UserFamilyFormScreenState extends ConsumerState<UserFamilyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _brothersController = TextEditingController();
  final _sistersController = TextEditingController();
  String? _familyType;

  @override
  void dispose() {
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _brothersController.dispose();
    _sistersController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_familyType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a family type')),
        );
        return;
      }

      ref
          .read(userFamilyControllerProvider.notifier)
          .saveFamily(
            fatherName: _fatherNameController.text,
            motherName: _motherNameController.text,
            brothers: int.parse(_brothersController.text),
            sisters: int.parse(_sistersController.text),
            familyType: _familyType!,
          );
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
      appBar: AppBar(title: const Text('Family Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
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

                const SizedBox(height: 20),
                if (familyState.isLoading)
                  const CircularProgressIndicator()
                else
                  AppButton(onPressed: _submitForm, text: 'Save Family'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
