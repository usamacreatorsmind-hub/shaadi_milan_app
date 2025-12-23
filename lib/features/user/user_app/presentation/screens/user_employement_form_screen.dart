import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/user_employment_controllers.dart';
import '../../domain/states/employee_state.dart';

@RoutePage()
class UserEmploymentFormScreen extends ConsumerStatefulWidget {
  const UserEmploymentFormScreen({super.key});

  @override
  ConsumerState<UserEmploymentFormScreen> createState() =>
      _UserEmploymentFormScreenState();
}

class _UserEmploymentFormScreenState
    extends ConsumerState<UserEmploymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _annualIncomeController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _annualIncomeController.dispose();
    super.dispose();
  }

  String? _jobType;
  final _designationController = TextEditingController();
  final _workLocationController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_jobType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a job type')),
        );
        return;
      }
      ref
          .read(userEmploymentControllerProvider.notifier)
          .saveEmployment(
            jobType: _jobType!,
            company: _companyController.text,
            designation: _designationController.text,
            annualIncome: int.tryParse(_annualIncomeController.text) ?? 0,
            workLocation: _workLocationController.text,
          );
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

    return Scaffold(
      appBar: AppBar(title: const Text('Employment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppDropDown(
                  label: "Job Type",
                  items: const ['Salaried', 'Business', 'Student', 'Other'],
                  value: _jobType,
                  onChanged: (value) {
                    setState(() => _jobType = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a job type';
                    }
                    return null;
                  },
                ),
                AppTextField(
                  controller: _companyController,
                  prefixIcon: Icons.business,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Company",
                  hint: "Enter your company name",
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

                AppTextField(
                  controller: _annualIncomeController,
                  prefixIcon: Icons.attach_money,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Annual Income",
                  hint: "Enter your annual income",
                  obscureText: false,
                  keyboardType: TextInputType.number,
                ),
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

                const SizedBox(height: 20),
                if (employmentState.isLoading)
                  const CircularProgressIndicator()
                else
                  AppButton(onPressed: _submitForm, text: 'Save Employment'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
