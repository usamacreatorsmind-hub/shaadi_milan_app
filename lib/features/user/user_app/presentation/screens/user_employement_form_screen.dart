import '../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../core/enums/enum.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/user_employment_controllers.dart';
import '../../domain/states/employee_state.dart';

@RoutePage()
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
  final _annualIncomeController = TextEditingController();

  final _designationController = TextEditingController();
  final _workLocationController = TextEditingController();

  String? _jobType;

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit &&
        widget.existingEmploymentProfile != null) {
      final profile = widget.existingEmploymentProfile!;
      _companyController.text = profile.company ?? "";
      _designationController.text = profile.designation ?? "";
      _annualIncomeController.text = profile.annualIncome.toString();
      _workLocationController.text = profile.workLocation ?? "";
      _jobType = profile.jobType;
    }
  }

  // @override
  // void dispose() {
  //   _companyController.dispose();
  //   _annualIncomeController.dispose();
  //   super.dispose();
  // }

  void _submitForm() {
    if (_jobType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLabels.selectJobType(context))));
      return;
    }

    // If "Not Working", skip validation and submit with null values
    if (_jobType == AppLabels.notWorking(context)) {
      final notifier = ref.read(userEmploymentControllerProvider.notifier);

      if (widget.mode == FormMode.create) {
        notifier.saveEmployment(
          jobType: _jobType!,
          company: null,
          designation: null,
          annualIncome: null,
          workLocation: null,
        );
      } else {
        notifier.updateEmployment(
          jobType: _jobType!,
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

      if (widget.mode == FormMode.create) {
        notifier.saveEmployment(
          jobType: _jobType!,
          company: _companyController.text.isEmpty
              ? null
              : _companyController.text,
          designation: _designationController.text.isEmpty
              ? null
              : _designationController.text,
          annualIncome: int.tryParse(_annualIncomeController.text),
          workLocation: _workLocationController.text.isEmpty
              ? null
              : _workLocationController.text,
        );
      } else {
        notifier.updateEmployment(
          jobType: _jobType!,
          company: _companyController.text.isEmpty
              ? null
              : _companyController.text,
          designation: _designationController.text.isEmpty
              ? null
              : _designationController.text,
          annualIncome: int.tryParse(_annualIncomeController.text),
          workLocation: _workLocationController.text.isEmpty
              ? null
              : _workLocationController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employmentState = ref.watch(userEmploymentControllerProvider);

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
      return ListView(
        shrinkWrap: true,
        children: [
          AppTextField(
            controller: _companyController,
            prefixIcon: Icons.business,
            iconColor: Theme.of(context).colorScheme.primary,
            label: AppLabels.organization(context),
            hint: AppLabels.organizationHint(context),
            obscureText: false,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _designationController,
            prefixIcon: Icons.work,
            iconColor: Theme.of(context).colorScheme.primary,
            label: AppLabels.designation(context),
            hint: AppLabels.designationHint(context),
            obscureText: false,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _workLocationController,
            prefixIcon: Icons.location_on,
            iconColor: Theme.of(context).colorScheme.primary,
            label: AppLabels.workLocation(context),
            hint: AppLabels.workLocationHint(context),
            obscureText: false,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _annualIncomeController,

            // indian currency
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
              AppDropDown(
                label: AppLabels.jobType(context),
                items: [
                  AppLabels.private(context),
                  AppLabels.government(context),
                  AppLabels.business(context),
                  AppLabels.defence(context),
                  AppLabels.selfEmployed(context),
                  AppLabels.notWorking(context),
                ],
                value: _jobType,
                onChanged: (value) {
                  setState(() => _jobType = value);
                },
              ),
              const SizedBox(height: 16),
              _jobType == AppLabels.notWorking(context) ? const SizedBox() : buildEmploymentForm(),

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
