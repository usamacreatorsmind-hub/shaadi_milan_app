import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/core/enums/enum.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/user_image_firestore.dart';

import '../../../../../app/custom/custom_widgets/validators.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import 'package:intl/intl.dart';
import '../controllers/user_identity_controllers.dart';
import '../../domain/states/identity_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class UserIdentityFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final IdentityProfile? existingIdentityProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserIdentityFormScreen({
    super.key,
    required this.mode,
    this.existingIdentityProfile,
    this.registerSubmit,
  });

  @override
  ConsumerState<UserIdentityFormScreen> createState() =>
      _UserIdentityFormScreenState();
}

class _UserIdentityFormScreenState
    extends ConsumerState<UserIdentityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadharController = TextEditingController();

  // prefile controlles

  String? _gender;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit &&
        widget.existingIdentityProfile != null) {
      _aadharController.text = widget.existingIdentityProfile!.aadhar;
      _gender = widget.existingIdentityProfile!.gender;
      _selectedDate = widget.existingIdentityProfile!.dob;
    }
  }

  // @override
  // void dispose() {
  //   _aadharController.dispose();
  //   super.dispose();
  // }

  // ----------------------------
  // DATE PICKER
  // ----------------------------
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "Select your date of birth",
      cancelText: "Cancel",
      confirmText: "Select",
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ----------------------------
  // AGE CALCULATION
  // ----------------------------
  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  // ✅ SAFE AGE GETTER
  int? get _age {
    if (_selectedDate == null) return null;
    return _calculateAge(_selectedDate!);
  }

  // ----------------------------
  // SUBMIT
  // ----------------------------
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select gender')));
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (_age! < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be at least 18 years old')),
      );
      return;
    }

    // ref
    //     .read(identityControllerProvider.notifier)
    //     .saveIdentity(
    //       gender: _gender!,
    //       dob: _selectedDate!,
    //       age: _age!,
    //       aadhar: _aadharController.text.trim(),
    //     );

    final notifier = ref.read(identityControllerProvider.notifier);

    if (widget.mode == FormMode.create) {
      notifier.saveIdentity(
        gender: _gender!,
        dob: _selectedDate!,
        age: _age!,
        aadhar: _aadharController.text.trim(),
      );
    } else {
      // Update logic (using saveIdentity as upsert)
      notifier.updateIdentity(
        gender: _gender!,
        dob: _selectedDate!,
        age: _age!,
        aadhar: _aadharController.text.trim(),
      );
    }
  }

  // ----------------------------
  // BUILD
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    final identityState = ref.watch(identityControllerProvider);

    ref.listen<IdentityState>(identityControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      }

      if (current.identity != null && previous?.identity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identity saved successfully')),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        title: Text(
          widget.mode == FormMode.create ? 'Create Identity' : 'Edit Identity',

          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 12),

              const SizedBox(height: 12),

              // ----------------------------
              // AADHAR
              // ----------------------------
              AppTextField(
                controller: _aadharController,
                maxLines: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  MaxLengthFormatter(max: 12),
                ],

                showWordCount: true,
                counterType: CounterType.characters, // ✅ IMPORTANT

                prefixIcon: Icons.credit_card,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Aadhar Number",
                hint: "Enter your Aadhar number",
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: Validators.validateAadhar,
              ),
              const SizedBox(height: 12),

              // Widget for Aadhar upload 

              // ----------------------------
              // GENDER
              // ----------------------------
              AppDropDown(
                label: "Gender",
                items: const ['Male', 'Female', 'Other'],
                value: _gender,
                onChanged: (value) {
                  setState(() => _gender = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ----------------------------
              // DOB PICKER
              // ----------------------------
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  child: Icon(
                    Icons.date_range_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  _selectedDate == null
                      ? 'Select Date of Birth'
                      : 'DOB: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                ),
                subtitle: _age == null ? null : Text('Age: $_age years'),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------
              // SUBMIT / AGE VALIDATION
              // ----------------------------
              if (_age == null)
                const SizedBox.shrink()
              else if (_age! >= 18)
                identityState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (widget.registerSubmit != null
                          ? const SizedBox.shrink()
                          : AppButton(
                              onPressed: _submitForm,
                              text: widget.mode == FormMode.create
                                  ? 'Save Identity'
                                  : 'Update Identity',
                            ))
              else
                const Text(
                  "You are not eligible to create a profile as you are under 18 years old.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
