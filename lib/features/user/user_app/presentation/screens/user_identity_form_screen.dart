import 'package:arvika_marriage_bureau/app/custom/image_picker/image_picker_widget.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../data/datasources/firebase/agent_firestore_ds.dart';
import '../../../user_auth/presentation/controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import '../controllers/user_identity_controllers.dart';
import '../../domain/states/identity_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class UserIdentityFormScreen extends ConsumerStatefulWidget {
  const UserIdentityFormScreen({super.key});

  @override
  ConsumerState<UserIdentityFormScreen> createState() =>
      _UserIdentityFormScreenState();
}

class _UserIdentityFormScreenState
    extends ConsumerState<UserIdentityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadharController = TextEditingController();

  String? _gender;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _aadharController.dispose();
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

    ref
        .read(identityControllerProvider.notifier)
        .saveIdentity(
          gender: _gender!,
          dob: _selectedDate!,
          age: _age!,
          aadhar: _aadharController.text.trim(),
        );
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
      appBar: AppBar(title: const Text('Identity Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 12),

              // ----------------------------
              // AADHAR
              // ----------------------------
              AppTextField(
                controller: _aadharController,
                prefixIcon: Icons.credit_card,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Aadhar Number",
                hint: "Enter your Aadhar number",
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Aadhar number is required';
                  }
                  if (value.length != 12) {
                    return 'Enter valid 12-digit Aadhar number';
                  }
                  return null;
                },
              ),

              // add  widget for  aadhar upload
              const SizedBox(height: 12),

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

              const SizedBox(height: 12),

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

              const SizedBox(height: 34),

              // ----------------------------
              // SUBMIT / AGE VALIDATION
              // ----------------------------
              if (_age == null)
                const SizedBox.shrink()
              else if (_age! >= 18)
                identityState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(onPressed: _submitForm, text: 'Save Identity')
              else
                const Text(
                  "You are not eligible to create a profile as you are under 18 years old.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 16),

              // // elevated button to fetch agent data
              // ElevatedButton(
              //   onPressed: () async {
              //     // Example: Fetch agent data using agentId from a text field
              //     // For demonstration, let's assume agentId is hardcoded or comes from another input
              //     final agentId = _aadharController.text
              //         .trim(); // Using aadhar field for agentId for example
              //     if (agentId.isEmpty) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           content: Text('Please enter an Agent ID to fetch data'),
              //         ),
              //       );
              //       return;
              //     }

              //     try {
              //       final agentData = await ref
              //           .read(agentFirestoreDsProvider)
              //           .fetchAgentbyAgentId(agentId);
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(
              //           content: Text('Agent Name: ${agentData}'),
              //           behavior: SnackBarBehavior.floating,
              //         ),
              //       );
              //     } catch (e) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(
              //           content: Text('Error fetching agent data: $e'),
              //           behavior: SnackBarBehavior.floating,
              //         ),
              //       );
              //     }
              //   },
              //   child: const Text('Fetch Agent Data (Example)'),
              // ),

              // navigate to cultural details
              AppButton(
                onPressed: () {
                  context.navigateTo(const UserAddressFormRoute());
                },
                text: "Go to address Details",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppImagePicker {
  final String title;
  final ValueChanged<String> onImagePicked;

  const AppImagePicker({required this.title, required this.onImagePicked});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Select Image'),
            onPressed: () async {
              // TODO: Implement image picking logic
              // For now, let's simulate a picked image path
              const String dummyImagePath = 'path/to/your/image.jpg';
              onImagePicked(dummyImagePath);
            },
          ),
        ],
      ),
    );
  }
}
