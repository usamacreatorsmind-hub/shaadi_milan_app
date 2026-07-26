import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_app/data/repositories_impl/user_repo_impl.dart';

import '../../../../../../app/custom/custom_widgets/validators.dart';
import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../../app/providers/global_providers.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/enums/enum.dart';
import '../../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../domain/states/identity_state.dart';
import '../../controllers/user_identity_controllers.dart';

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
  final _aboutMeEnController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit &&
        widget.existingIdentityProfile != null) {
      _aadharController.text = widget.existingIdentityProfile!.aadhar;
      _aboutMeController.text = widget.existingIdentityProfile!.aboutMe.hi;
      _aboutMeEnController.text = widget.existingIdentityProfile!.aboutMe.en;

      _selectedDate = widget.existingIdentityProfile!.dob;
    }
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _aboutMeController.dispose();
    _aboutMeEnController.dispose();
    super.dispose();
  }

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

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  int? get _age {
    if (_selectedDate == null) return null;
    return _calculateAge(_selectedDate!);
  }

  Future<void> _submitForm() async {
    final targetUid = ref.read(targetUserIdProvider);
    if (targetUid == null) return;

    BilingualValue gender = BilingualValue.empty();
    try {
      final user = await ref
          .read(userRepositoryProvider)
          .fetchUser(targetUid);

      if (!mounted) return;
      gender = user.gender;
    } catch (e) {
      print(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLabels.errorFetchingUserData(context, e.toString()),
            ),
          ),
        );
      }
      return;
    }

    if (gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLabels.genderNotFound(context))),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(identityControllerProvider.notifier);
    final aboutMe = BilingualValue(
      hi: _aboutMeController.text.trim(),
      en: _aboutMeEnController.text.trim(),
    );

    final dob = _selectedDate ?? DateTime(1900);
    final ageValue = _age ?? 0;

    if (widget.mode == FormMode.create) {
      notifier.saveIdentity(
        gender: gender,
        dob: dob,
        age: ageValue,
        aadhar: _aadharController.text.trim(),
        aboutMe: aboutMe,
      );
    } else {
      notifier.updateIdentity(
        gender: gender,
        dob: dob,
        age: ageValue,
        aadhar: _aadharController.text.trim(),
        aboutMe: aboutMe,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final identityState = ref.watch(identityControllerProvider);

    ref.listen<IdentityState>(identityControllerProvider, (previous, current) {
      if (current.error != null) {
        print(current.error);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLabels.error(context, current.error.toString()))));
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
          widget.mode == FormMode.create
              ? AppLabels.createIdentity(context)
              : AppLabels.editIdentity(context),
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
              BilingualTextField(
                controller: _aboutMeController,
                englishController: _aboutMeEnController,
                prefixIcon: Icons.person_outline,
                label: AppLabels.aboutMe(context),
                hint: AppLabels.tellUsAboutYourself(context),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _aadharController,
                maxLines: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  MaxLengthFormatter(max: 12),
                ],
                showWordCount: true,
                counterType: CounterType.characters,
                prefixIcon: Icons.credit_card,
                iconColor: Theme.of(context).colorScheme.primary,
                label: AppLabels.aadharNumber(context),
                hint: AppLabels.enterAadharNumber(context),
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return Validators.validateAadhar(context, value);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
                      : AppLabels.dobValue(
                          context,
                          DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        ),
                ),
                subtitle: _age == null
                    ? null
                    : Text(AppLabels.ageYears(context, _age!)),
                onTap: widget.mode == FormMode.edit ? null : () => _selectDate(context),
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
              identityState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (widget.registerSubmit != null
                      ? const SizedBox.shrink()
                      : AppButton(
                          onPressed: _submitForm,
                          text: widget.mode == FormMode.create
                              ? AppLabels.saveIdentity(context)
                              : AppLabels.updateIdentity(context),
                        )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
