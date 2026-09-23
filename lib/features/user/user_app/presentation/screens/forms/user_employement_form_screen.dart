import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/enums/enum.dart';
import '../../../../../translitration/models/bilingual_value.dart';
import '../../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../domain/states/employee_state.dart';
import '../../controllers/user_employment_controllers.dart';

@RoutePage()
class UserEmploymentFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final EmploymentProfile? existingEmploymentProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserEmploymentFormScreen({super.key, required this.mode, required this.existingEmploymentProfile, this.registerSubmit});

  @override
  ConsumerState<UserEmploymentFormScreen> createState() => _UserEmploymentFormScreenState();
}

class _UserEmploymentFormScreenState extends ConsumerState<UserEmploymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _companyEnController = TextEditingController();

  final _designationHiCtrl = TextEditingController();
  final _designationEnCtrl = TextEditingController();
  bool _isManualDesignation = false;

  final _jobTypeHiCtrl = TextEditingController();
  final _jobTypeEnCtrl = TextEditingController();
  bool _isManualJobType = false;

  final _districtEmploymentHiCtrl = TextEditingController();
  final _districtEmploymentEnCtrl = TextEditingController();

  BilingualValue? _selectedDesignation;
  BilingualValue? _selectedAnnualIncome;

  final List<BilingualValue> _customIncomeOptions = [
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

  final _workLocationController = TextEditingController();
  final _workLocationEnController = TextEditingController();

  BilingualValue? _selectedJobType;

  final Map<String, BilingualValue> _jobTypeOptions = {
    'Private': BilingualValue(hi: 'निजी', en: 'Private'),
    'Government': BilingualValue(hi: 'सरकारी', en: 'Government'),
    'Business': BilingualValue(hi: 'व्यापार', en: 'Business'),
    'Defence': BilingualValue(hi: 'रक्षा', en: 'Defence'),
    'Self Employed': BilingualValue(hi: 'स्व-नियोजित', en: 'Self Employed'),
    'Not Working': BilingualValue(hi: 'कार्य नहीं कर रहे', en: 'Not Working'),
  };

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit && widget.existingEmploymentProfile != null) {
      final profile = widget.existingEmploymentProfile!;
      _companyController.text = profile.company?.hi ?? "";
      _companyEnController.text = profile.company?.en ?? "";

      _selectedDesignation = profile.designation;
      if (profile.designation != null) {
        _designationHiCtrl.text = profile.designation!.hi;
        _designationEnCtrl.text = profile.designation!.en;
        _isManualDesignation = true;
      }
      
      if (profile.annualIncome != null) {
        _selectedAnnualIncome = _customIncomeOptions.firstWhere((e) => e.en == profile.annualIncome?.en, orElse: () => profile.annualIncome!);
      }

      _workLocationController.text = profile.workLocation?.hi ?? "";
      _workLocationEnController.text = profile.workLocation?.en ?? "";

      _districtEmploymentHiCtrl.text = profile.districtEmployment?.hi ?? "";
      _districtEmploymentEnCtrl.text = profile.districtEmployment?.en ?? "";

      _selectedJobType = _jobTypeOptions.values.firstWhere((e) => e.en == profile.jobType.en, orElse: () {
        _isManualJobType = true;
        _jobTypeHiCtrl.text = profile.jobType.hi;
        _jobTypeEnCtrl.text = profile.jobType.en;
        return profile.jobType;
      });
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _companyEnController.dispose();
    _workLocationController.dispose();
    _workLocationEnController.dispose();
    _designationHiCtrl.dispose();
    _designationEnCtrl.dispose();
    _jobTypeHiCtrl.dispose();
    _jobTypeEnCtrl.dispose();
    _districtEmploymentHiCtrl.dispose();
    _districtEmploymentEnCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    final notifier = ref.read(userEmploymentControllerProvider.notifier);
    
    final jobTypeValue = _isManualJobType 
      ? BilingualValue(hi: _jobTypeHiCtrl.text.trim(), en: _jobTypeEnCtrl.text.trim())
      : (_selectedJobType ?? _jobTypeOptions['Not Working']!);

    // If "Not Working" or null, submit with null values
    if (jobTypeValue.en == 'Not Working') {
      if (widget.mode == FormMode.create) {
        notifier.saveEmployment(jobType: jobTypeValue, company: null, designation: null, annualIncome: null, workLocation: null, districtEmployment: null);
      } else {
        notifier.updateEmployment(jobType: jobTypeValue, company: null, designation: null, annualIncome: null, workLocation: null, districtEmployment: null);
      }

      return;
    }

    // For other job types, save whatever is filled
    final company = _companyController.text.isEmpty ? null : BilingualValue(hi: _companyController.text, en: _companyEnController.text);
    final workLocation = _workLocationController.text.isEmpty
        ? null
        : BilingualValue(hi: _workLocationController.text, en: _workLocationEnController.text);

    final designationValue = _isManualDesignation
        ? BilingualValue(hi: _designationHiCtrl.text.trim(), en: _designationEnCtrl.text.trim())
        : _selectedDesignation;
    
    final districtEmploymentValue = _districtEmploymentHiCtrl.text.isEmpty 
      ? null 
      : BilingualValue(hi: _districtEmploymentHiCtrl.text.trim(), en: _districtEmploymentEnCtrl.text.trim());

    if (widget.mode == FormMode.create) {
      notifier.saveEmployment(
        jobType: jobTypeValue,
        company: company,
        designation: designationValue,
        annualIncome: _selectedAnnualIncome,
        workLocation: workLocation,
        districtEmployment: districtEmploymentValue,
      );
    } else {
      notifier.updateEmployment(
        jobType: jobTypeValue,
        company: company,
        designation: designationValue,
        annualIncome: _selectedAnnualIncome,
        workLocation: workLocation,
        districtEmployment: districtEmploymentValue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final employmentState = ref.watch(userEmploymentControllerProvider);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    ref.listen<EmploymentState>(userEmploymentControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.error(context, current.error.toString()))));
      } else if (current.employment != null && previous?.employment == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.employmentSavedSuccessfully(context))));
      }
    });

    Widget buildEmploymentForm() {
      final isHindi = Localizations.localeOf(context).languageCode == 'hi';
      return Column(
        children: [
          BilingualTextField(
            controller: _companyController,
            englishController: _companyEnController,
            prefixIcon: Icons.business,
            label: AppLabels.organization(context),
            hint: AppLabels.organizationHint(context),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text("Type Designation Manually"),
            value: _isManualDesignation,
            onChanged: (val) {
              setState(() {
                _isManualDesignation = val ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          if (_isManualDesignation) ...[
            BilingualTextField(
              controller: _designationHiCtrl,
              englishController: _designationEnCtrl,
              prefixIcon: Icons.work_outline,
              label: "Designation",
              hint: "Enter designation name",
            ),
          ] else ...[
            Consumer(
              builder: (context, ref, child) {
                final designationsAsync = ref.watch(designationsProvider);
                return designationsAsync.when(
                  data: (items) => AppDropDown<BilingualValue>(
                    label: AppLabels.designation(context),
                    items: items,
                    value: _selectedDesignation,
                    itemLabel: (d) => isHindi ? d.hi : d.en,
                    onChanged: (val) => setState(() => _selectedDesignation = val),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text("Error loading designations"),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          BilingualTextField(
            controller: _workLocationController,
            englishController: _workLocationEnController,
            prefixIcon: Icons.location_on,
            label: AppLabels.workLocation(context),
            hint: AppLabels.workLocationHint(context),
          ),
          const SizedBox(height: 16),
          BilingualTextField(
            controller: _districtEmploymentHiCtrl,
            englishController: _districtEmploymentEnCtrl,
            prefixIcon: Icons.map_outlined,
            label: "District Employment",
            hint: "Enter district of employment",
          ),
          const SizedBox(height: 16),
          AppDropDown<BilingualValue>(
            label: AppLabels.annualIncome(context),
            items: _customIncomeOptions,
            value: _selectedAnnualIncome,
            itemLabel: (i) => isHindi ? i.hi : i.en,
            onChanged: (val) => setState(() => _selectedAnnualIncome = val),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.employmentDetails(context), style: Theme.of(context).textTheme.headlineMedium)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CheckboxListTile(
                title: const Text("Type Job Type Manually"),
                value: _isManualJobType,
                onChanged: (val) {
                  setState(() {
                    _isManualJobType = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              if (_isManualJobType) ...[
                BilingualTextField(
                  controller: _jobTypeHiCtrl,
                  englishController: _jobTypeEnCtrl,
                  prefixIcon: Icons.work_history_outlined,
                  label: "Job Type",
                  hint: "Enter job type",
                ),
              ] else ...[
                AppDropDown<BilingualValue>(
                  label: AppLabels.jobType(context),
                  items: _jobTypeOptions.values.toList(),
                  value: _selectedJobType,
                  itemLabel: (job) => isHindi ? job.hi : job.en,
                  onChanged: (value) {
                    setState(() => _selectedJobType = value);
                  },
                ),
              ],
              const SizedBox(height: 16),
              (_isManualJobType || (_selectedJobType?.en != 'Not Working')) ? buildEmploymentForm() : const SizedBox(),

              const SizedBox(height: 25),

              const SizedBox(height: 20),
              if (employmentState.isLoading)
                const CircularProgressIndicator()
              else
                (widget.registerSubmit != null
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: double.infinity,
                        child: AppButton(onPressed: _submitForm, text: AppLabels.saveEmployment(context)),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
