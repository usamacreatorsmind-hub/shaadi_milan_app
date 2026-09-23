import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';

import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/enums/enum.dart';
import '../../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../domain/states/family_state.dart';
import '../../controllers/user_family_controllers.dart';

@RoutePage()
class UserFamilyFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final FamilyProfile? existingFamilyProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserFamilyFormScreen({super.key, required this.mode, required this.existingFamilyProfile, this.registerSubmit});

  @override
  ConsumerState<UserFamilyFormScreen> createState() => _UserFamilyFormScreenState();
}

class _UserFamilyFormScreenState extends ConsumerState<UserFamilyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fatherNameController = TextEditingController();
  final _fatherNameEnController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherNameEnController = TextEditingController();
  final _brothersController = TextEditingController();
  final _familyStatusController = TextEditingController();
  final _sistersController = TextEditingController();

  BilingualValue? _selectedFamilyIncome;
  String? _familyType;

  final List<BilingualValue> _incomeOptions = [
    BilingualValue(hi: '₹25,000–₹30,000', en: '₹25,000–₹30,000'),
    BilingualValue(hi: '₹30,000–₹35,000', en: '₹30,000–₹35,000'),
    BilingualValue(hi: '₹35,000–₹40,000', en: '₹35,000–₹40,000'),
    BilingualValue(hi: '₹40,000–₹50,000', en: '₹40,000–₹50,000'),
    BilingualValue(hi: '₹50,000–₹55,000', en: '₹50,000–₹55,000'),
    BilingualValue(hi: '₹55,000–₹60,000', en: '₹55,000–₹60,000'),
    BilingualValue(hi: '₹60,000–₹70,000', en: '₹60,000–₹70,000'),
    BilingualValue(hi: '₹70,000–₹75,000', en: '₹70,000–₹75,000'),
    BilingualValue(hi: '₹75,000–₹80,000', en: '₹75,000–₹80,000'),
    BilingualValue(hi: '₹80,000–₹85,000', en: '₹80,000–₹85,000'),
    BilingualValue(hi: '₹85,000–₹90,000', en: '₹85,000–₹90,000'),
    BilingualValue(hi: '₹90,000–₹95,000', en: '₹90,000–₹95,000'),
    BilingualValue(hi: '₹95,000–₹1,00,000', en: '₹95,000–₹1,00,000'),
    BilingualValue(hi: 'Above ₹1 Crore', en: 'Above ₹1 Crore'),
  ];

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit && widget.existingFamilyProfile != null) {
      final profile = widget.existingFamilyProfile!;
      _fatherNameController.text = profile.fatherName.hi;
      _fatherNameEnController.text = profile.fatherName.en;
      _motherNameController.text = profile.motherName.hi;
      _motherNameEnController.text = profile.motherName.en;
      _brothersController.text = profile.numberOfBrothers.toString();
      _sistersController.text = profile.numberOfSisters.toString();
      _familyType = profile.familyType.en;
      _familyStatusController.text = profile.familyStatus.en;
      if (profile.familyIncome != null) {
        _selectedFamilyIncome = _incomeOptions.where((e) => e.en == profile.familyIncome?.en).firstOrNull ?? profile.familyIncome;
      }
    }
  }

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    final notifier = ref.read(userFamilyControllerProvider.notifier);
    final familyType = _familyType ?? AppLabels.preferNotToSay(context);
    final familyStatus = _familyStatusController.text.isEmpty ? AppLabels.preferNotToSay(context) : _familyStatusController.text;

    final fatherName = BilingualValue(hi: _fatherNameController.text.trim(), en: _fatherNameEnController.text.trim());
    final motherName = BilingualValue(hi: _motherNameController.text.trim(), en: _motherNameEnController.text.trim());

    if (widget.mode == FormMode.create) {
      notifier.saveFamily(
        fatherName: fatherName,
        motherName: motherName,
        brothers: int.tryParse(_brothersController.text) ?? 0,
        sisters: int.tryParse(_sistersController.text) ?? 0,
        familyType: BilingualValue(hi: familyType, en: familyType),
        familyStatus: BilingualValue(hi: familyStatus, en: familyStatus),
        familyIncome: _selectedFamilyIncome,
      );
    } else {
      notifier.updateFamily(
        fatherName: fatherName,
        motherName: motherName,
        brothers: int.tryParse(_brothersController.text) ?? 0,
        sisters: int.tryParse(_sistersController.text) ?? 0,
        familyType: BilingualValue(hi: familyType, en: familyType),
        familyStatus: BilingualValue(hi: familyStatus, en: familyStatus),
        familyIncome: _selectedFamilyIncome,
      );
    }
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _fatherNameEnController.dispose();
    _motherNameController.dispose();
    _motherNameEnController.dispose();
    _brothersController.dispose();
    _familyStatusController.dispose();
    _sistersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(userFamilyControllerProvider);

    ref.listen<FamilyState>(userFamilyControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.error(context, current.error.toString()))));
      } else if (current.family != null && previous?.family == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.familyProfileSavedSuccessfully(context))));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.familyDetails(context), style: Theme.of(context).textTheme.headlineMedium)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BilingualTextField(
                controller: _fatherNameController,
                englishController: _fatherNameEnController,
                prefixIcon: Icons.person,
                label: AppLabels.fatherName(context),
                hint: AppLabels.fatherNameHint(context),
              ),
              const SizedBox(height: 16),
              BilingualTextField(
                controller: _motherNameController,
                englishController: _motherNameEnController,
                prefixIcon: Icons.person,
                label: AppLabels.motherName(context),
                hint: AppLabels.motherNameHint(context),
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
                items: [AppLabels.jointFamily(context), AppLabels.nuclearFamily(context), AppLabels.preferNotToSay(context)],
                value: _familyType,
                itemLabel: (type) => type,
                onChanged: (value) {
                  setState(() => _familyType = value);
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
                value: _familyStatusController.text.isEmpty ? null : _familyStatusController.text,
                itemLabel: (status) => status,
                onChanged: (value) {
                  setState(() => _familyStatusController.text = value!);
                },
              ),
              const SizedBox(height: 16),
              AppDropDown<BilingualValue>(
                label: "Family Annual Income",
                items: _incomeOptions,
                value: _selectedFamilyIncome,
                itemLabel: (i) => i.en,
                onChanged: (val) => setState(() => _selectedFamilyIncome = val),
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
