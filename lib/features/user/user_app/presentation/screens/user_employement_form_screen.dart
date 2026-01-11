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
      ).showSnackBar(const SnackBar(content: Text('Please select a job type')));
      return;
    }

    // If "Not Working", skip validation and submit with null values
    if (_jobType == 'Not Working') {
      final notifier = ref.read(userEmploymentControllerProvider.notifier);

      if (widget.mode == FormMode.create) {
        notifier.saveEmployment(
          jobType: _jobType!,
          company: null,
          designation: null,
          annualIncome: int.tryParse(_annualIncomeController.text),
          workLocation: null,
        );
      } else {
        notifier.updateEmployment(
          jobType: _jobType!,
          company: null,
          designation: null,
          annualIncome: int.tryParse(_annualIncomeController.text),
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
          const SnackBar(
            content: Text('Employment profile saved successfully!'),
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
            label: "Organaization",
            hint: "Enter your Organaization name",
            obscureText: false,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _designationController,
            prefixIcon: Icons.work,
            iconColor: Theme.of(context).colorScheme.primary,
            label: "Designation",
            hint: "Enter your designation",
            obscureText: false,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),

          AppTextField(
            controller: _workLocationController,
            prefixIcon: Icons.location_on,
            iconColor: Theme.of(context).colorScheme.primary,
            label: "Work Location",
            hint: "Enter your work location",
            obscureText: false,
            keyboardType: TextInputType.text,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employment Details',
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
                label: "Job Type",
                items: const [
                  'Private',
                  'Government',
                  'Business',
                  'Defence',

                  'Self Employed',
                  'Not Working',
                ],
                value: _jobType,
                onChanged: (value) {
                  setState(() => _jobType = value);
                },
              ),
              const SizedBox(height: 16),
              _jobType == "Not Working" ? SizedBox() : buildEmploymentForm(),

              SizedBox(height: 25),
              AppTextField(
                controller: _annualIncomeController,

                // indian currency
                prefixIcon: Icons.currency_rupee,

                iconColor: Theme.of(context).colorScheme.primary,
                label: "Annual Income",
                hint: "Enter your annual income",
                obscureText: false,
                keyboardType: TextInputType.number,
              ),

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
                          text: 'Save Employment',
                        ),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
