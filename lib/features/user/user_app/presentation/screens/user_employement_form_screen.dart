import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../core/constants/app_labels.dart';
import '../../../../../core/enums/enum.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../../../translitration/widgets/bilingual_text_field.dart';
import '../../domain/states/employee_state.dart';
import '../controllers/user_employment_controllers.dart';

class UserEmploymentFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final EmploymentProfile? existingEmploymentProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserEmploymentFormScreen({
    super.key,
    required this.mode,
    required this.existingEmploymentProfile,
    this.registerSubmit,
  });

  @override
  ConsumerState<UserEmploymentFormScreen> createState() =>
      _UserEmploymentFormScreenState();
}

class _UserEmploymentFormScreenState
    extends ConsumerState<UserEmploymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _companyEnController = TextEditingController();

  final _annualIncomeController = TextEditingController();

  final _designationController = TextEditingController();
  final _designationEnController = TextEditingController();

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
    if (widget.mode == FormMode.edit &&
        widget.existingEmploymentProfile != null) {
      final profile = widget.existingEmploymentProfile!;
      _companyController.text = profile.company?.hi ?? "";
      _companyEnController.text = profile.company?.en ?? "";

      _designationController.text = profile.designation?.hi ?? "";
      _designationEnController.text = profile.designation?.en ?? "";

      _annualIncomeController.text = profile.annualIncome?.toString() ?? "";

      _workLocationController.text = profile.workLocation?.hi ?? "";
      _workLocationEnController.text = profile.workLocation?.en ?? "";

      _selectedJobType = _jobTypeOptions.values.firstWhere(
        (e) => e.en == profile.jobType.en,
        orElse: () => profile.jobType,
      );
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _companyEnController.dispose();
    _annualIncomeController.dispose();
    _designationController.dispose();
    _designationEnController.dispose();
    _workLocationController.dispose();
    _workLocationEnController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_selectedJobType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLabels.selectJobType(context))));
      return;
    }

    // If "Not Working", skip validation and submit with null values
    if (_selectedJobType!.en == 'Not Working') {
      final notifier = ref.read(userEmploymentControllerProvider.notifier);

      if (widget.mode == FormMode.create) {
        notifier.saveEmployment(
          jobType: _selectedJobType!,
          company: null,
          designation: null,
          annualIncome: null,
          workLocation: null,
        );
      } else {
        notifier.updateEmployment(
          jobType: _selectedJobType!,
          company: null,
          designation: null,
          annualIncome: null,
          workLocation: null,
        );
      }

      return;
    }

    // For other job types, validate form
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(userEmploymentControllerProvider.notifier);

      final company = _companyController.text.isEmpty
          ? null
          : BilingualValue(
              hi: _companyController.text,
              en: _companyEnController.text,
            );
      final designation = _designationController.text.isEmpty
          ? null
          : BilingualValue(
              hi: _designationController.text,
              en: _designationEnController.text,
            );
      final workLocation = _workLocationController.text.isEmpty
          ? null
          : BilingualValue(
              hi: _workLocationController.text,
              en: _workLocationEnController.text,
            );

      if (widget.mode == FormMode.create) {
        notifier.saveEmployment(
          jobType: _selectedJobType!,
          company: company,
          designation: designation,
          annualIncome: int.tryParse(_annualIncomeController.text),
          workLocation: workLocation,
        );
      } else {
        notifier.updateEmployment(
          jobType: _selectedJobType!,
          company: company,
          designation: designation,
          annualIncome: int.tryParse(_annualIncomeController.text),
          workLocation: workLocation,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employmentState = ref.watch(userEmploymentControllerProvider);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    ref.listen<EmploymentState>(userEmploymentControllerProvider, (
      previous,
      current,
    ) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      } else if (current.employment != null && previous?.employment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLabels.employmentSavedSuccessfully(context)),
          ),
        );
      }
    });

    Widget buildEmploymentForm() {
      return Column(
        children: [
          BilingualTextField(
            controller: _companyController,
            englishController: _companyEnController,
            prefixIcon: Icons.business,
            label: AppLabels.organization(context),
            hint: AppLabels.organizationHint(context),
            validator: (v) =>
                v == null || v.isEmpty ? AppLabels.isRequired(context) : null,
          ),
          const SizedBox(height: 16),

          BilingualTextField(
            controller: _designationController,
            englishController: _designationEnController,
            prefixIcon: Icons.work,
            label: AppLabels.designation(context),
            hint: AppLabels.designationHint(context),
            validator: (v) =>
                v == null || v.isEmpty ? AppLabels.isRequired(context) : null,
          ),
          const SizedBox(height: 16),

          BilingualTextField(
            controller: _workLocationController,
            englishController: _workLocationEnController,
            prefixIcon: Icons.location_on,
            label: AppLabels.workLocation(context),
            hint: AppLabels.workLocationHint(context),
            validator: (v) =>
                v == null || v.isEmpty ? AppLabels.isRequired(context) : null,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _annualIncomeController,
            prefixIcon: Icons.currency_rupee,
            iconColor: Theme.of(context).colorScheme.primary,
            label: AppLabels.annualIncome(context),
            hint: AppLabels.annualIncomeHint(context),
            obscureText: false,
            keyboardType: TextInputType.number,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLabels.employmentDetails(context),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppDropDown<BilingualValue>(
                label: AppLabels.jobType(context),
                items: _jobTypeOptions.values.toList(),
                value: _selectedJobType,
                itemLabel: (job) => isHindi ? job.hi : job.en,
                onChanged: (value) {
                  setState(() => _selectedJobType = value);
                },
              ),
              const SizedBox(height: 16),
              _selectedJobType?.en == 'Not Working'
                  ? const SizedBox()
                  : buildEmploymentForm(),

              const SizedBox(height: 25),

              const SizedBox(height: 20),
              if (employmentState.isLoading)
                const CircularProgressIndicator()
              else
                (widget.registerSubmit != null
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: _submitForm,
                          text: AppLabels.saveEmployment(context),
                        ),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
