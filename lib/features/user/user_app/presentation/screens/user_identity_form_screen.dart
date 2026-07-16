import 'package:shadi_milan/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../core/enums/enum.dart';

import '../../../../../core/constants/app_labels.dart';
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
  final _aboutMeController = TextEditingController();

  // prefile controlles
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit &&
        widget.existingIdentityProfile != null) {
      _aadharController.text = widget.existingIdentityProfile!.aadhar ?? '';
      _aboutMeController.text = widget.existingIdentityProfile!.aboutMe ?? '';

      _selectedDate = widget.existingIdentityProfile!.dob;
    }
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  // ----------------------------
  // DATE PICKER
  // ----------------------------
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: AppLabels.selectDobHelp(context),
      cancelText: AppLabels.cancel(context),
      confirmText: AppLabels.selectDobConfirm(context),
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
  Future<void> _submitForm() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String gender = '';
    try {
      final user = await ref
          .read(userRepositoryProvider)
          .fetchUser(currentUser.uid);

      if (!mounted) return;

      gender = user.gender;
      debugPrint(user.gender);
      debugPrint(user.uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLabels.errorFetchingUserData(context, e.toString()))));
      }
      return;
    }

    if (gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLabels.genderNotFound(context)),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLabels.pleaseSelectDob(context))),
      );
      return;
    }

    if (_age! < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLabels.mustBe18(context))),
      );
      return;
    }

    // print all data
    print('DOB: $_selectedDate');
    print('Age: $_age');
    print('Aadhar: ${_aadharController.text.trim()}');
    print('About Me: ${_aboutMeController.text.trim()}');

    final notifier = ref.read(identityControllerProvider.notifier);

    if (widget.mode == FormMode.create) {
      // fetch gender form user collection from firebase
      //

      notifier.saveIdentity(
        gender: gender,
        dob: _selectedDate!,
        age: _age!,
        aadhar: _aadharController.text.trim(),
        aboutMe: _aboutMeController.text.trim(),
      );
    } else {
      // Update logic (using saveIdentity as upsert)
      notifier.updateIdentity(
        gender: gender,

        dob: _selectedDate!,
        age: _age!,
        aadhar: _aadharController.text.trim(),

        aboutMe: _aboutMeController.text.trim(),
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
          SnackBar(content: Text(AppLabels.identitySavedSuccessfully(context))),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        title: Text(
          widget.mode == FormMode.create ? AppLabels.createIdentity(context) : AppLabels.editIdentity(context),

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
              // about me field
              AppTextField(
                controller: _aboutMeController,
                prefixIcon: Icons.person_outline,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.aboutMe(context),
                hint: AppLabels.tellUsAboutYourself(context),

                showWordCount: true,
                counterType: CounterType.words,

                obscureText: false,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? AppLabels.isRequired(context) : null,
              ),
              const SizedBox(height: 16),

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
                label: AppLabels.aadharNumber(context),
                hint: AppLabels.enterAadharNumber(context),
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateAadhar(context, value),
              ),
              const SizedBox(height: 12),

              // Widget for Aadhar upload

              // ----------------------------
              // GENDER
              // ----------------------------
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
                      ? AppLabels.selectDateOfBirth(context)
                      : AppLabels.dobValue(context, DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                ),
                subtitle: _age == null ? null : Text(AppLabels.ageYears(context, _age!)),
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
                                  ? AppLabels.saveIdentity(context)
                                  : AppLabels.updateIdentity(context),
                            ))
              else
                Text(
                  AppLabels.notEligibleUnder18(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
