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

  final _jobTypeHiCtrl = TextEditingController();
  final _jobTypeEnCtrl = TextEditingController();

  final _annualIncomeHiCtrl = TextEditingController();
  final _annualIncomeEnCtrl = TextEditingController();

  final _districtEmploymentHiCtrl = TextEditingController();
  final _districtEmploymentEnCtrl = TextEditingController();

  final _workLocationController = TextEditingController();
  final _workLocationEnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit && widget.existingEmploymentProfile != null) {
      final profile = widget.existingEmploymentProfile!;
      _companyController.text = profile.company?.hi ?? "";
      _companyEnController.text = profile.company?.en ?? "";

      _jobTypeHiCtrl.text = profile.jobType.hi;
      _jobTypeEnCtrl.text = profile.jobType.en;

      _designationHiCtrl.text = profile.designation?.hi ?? "";
      _designationEnCtrl.text = profile.designation?.en ?? "";

      _annualIncomeHiCtrl.text = profile.annualIncome?.hi ?? "";
      _annualIncomeEnCtrl.text = profile.annualIncome?.en ?? "";

      _workLocationController.text = profile.workLocation?.hi ?? "";
      _workLocationEnController.text = profile.workLocation?.en ?? "";

      _districtEmploymentHiCtrl.text = profile.districtEmployment?.hi ?? "";
      _districtEmploymentEnCtrl.text = profile.districtEmployment?.en ?? "";
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
    _annualIncomeHiCtrl.dispose();
    _annualIncomeEnCtrl.dispose();
    _districtEmploymentHiCtrl.dispose();
    _districtEmploymentEnCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    final notifier = ref.read(userEmploymentControllerProvider.notifier);
    
    final jobTypeValue = BilingualValue(hi: _jobTypeHiCtrl.text.trim(), en: _jobTypeEnCtrl.text.trim());
    final company = _companyController.text.trim().isEmpty && _companyEnController.text.trim().isEmpty 
        ? null 
        : BilingualValue(hi: _companyController.text.trim(), en: _companyEnController.text.trim());
    
    final designationValue = _designationHiCtrl.text.trim().isEmpty && _designationEnCtrl.text.trim().isEmpty 
        ? null 
        : BilingualValue(hi: _designationHiCtrl.text.trim(), en: _designationEnCtrl.text.trim());
    
    final annualIncomeValue = _annualIncomeHiCtrl.text.trim().isEmpty && _annualIncomeEnCtrl.text.trim().isEmpty 
        ? null 
        : BilingualValue(hi: _annualIncomeHiCtrl.text.trim(), en: _annualIncomeEnCtrl.text.trim());
    
    final workLocation = _workLocationController.text.trim().isEmpty && _workLocationEnController.text.trim().isEmpty
        ? null
        : BilingualValue(hi: _workLocationController.text.trim(), en: _workLocationEnController.text.trim());
    
    final districtEmploymentValue = _districtEmploymentHiCtrl.text.trim().isEmpty && _districtEmploymentEnCtrl.text.trim().isEmpty 
        ? null 
        : BilingualValue(hi: _districtEmploymentHiCtrl.text.trim(), en: _districtEmploymentEnCtrl.text.trim());

    if (widget.mode == FormMode.create) {
      notifier.saveEmployment(
        jobType: jobTypeValue,
        company: company,
        designation: designationValue,
        annualIncome: annualIncomeValue,
        workLocation: workLocation,
        districtEmployment: districtEmploymentValue,
      );
    } else {
      notifier.updateEmployment(
        jobType: jobTypeValue,
        company: company,
        designation: designationValue,
        annualIncome: annualIncomeValue,
        workLocation: workLocation,
        districtEmployment: districtEmploymentValue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final employmentState = ref.watch(userEmploymentControllerProvider);

    ref.listen<EmploymentState>(userEmploymentControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.error(context, current.error.toString()))));
      } else if (current.employment != null && previous?.employment == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.employmentSavedSuccessfully(context))));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.employmentDetails(context), style: Theme.of(context).textTheme.headlineMedium)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              BilingualTextField(
                controller: _jobTypeHiCtrl,
                englishController: _jobTypeEnCtrl,
                prefixIcon: Icons.work_history_outlined,
                label: "Job Type",
                hint: "Enter job type (e.g. Private, Government)",
              ),
              const SizedBox(height: 16),
              BilingualTextField(
                controller: _companyController,
                englishController: _companyEnController,
                prefixIcon: Icons.business,
                label: AppLabels.organization(context),
                hint: AppLabels.organizationHint(context),
              ),
              const SizedBox(height: 16),
              BilingualTextField(
                controller: _designationHiCtrl,
                englishController: _designationEnCtrl,
                prefixIcon: Icons.work_outline,
                label: "Designation",
                hint: "Enter designation",
              ),
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
              BilingualTextField(
                controller: _annualIncomeHiCtrl,
                englishController: _annualIncomeEnCtrl,
                prefixIcon: Icons.currency_rupee,
                label: AppLabels.annualIncome(context),
                hint: "Enter annual income (Self Income)",
              ),
              const SizedBox(height: 25),
              if (employmentState.isLoading)
                const Center(child: CircularProgressIndicator())
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
