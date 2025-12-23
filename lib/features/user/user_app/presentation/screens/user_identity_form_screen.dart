import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_biodata_check_screen.dart';

import '../../../../../app/custom/image_picker/image_picker_widget.dart';
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

    final age = _calculateAge(_selectedDate!);

    ref
        .read(identityControllerProvider.notifier)
        .saveIdentity(
          gender: _gender!,
          dob: _selectedDate!,
          age: age,
          aadhar: _aadharController.text.trim(),
        );
  }

  // ----------------------------
  // BUILD
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    final identityState = ref.watch(identityControllerProvider);

    /// ✅ CORRECT PLACE FOR ref.listen
    ref.listen<IdentityState>(identityControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      }

      if (current.identity != null && previous?.identity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identity profile saved successfully')),
        );

        /// OPTIONAL: move to next step
        // context.router.push(const AddressFormRoute());
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

              AppTextField(
                controller: _aadharController,
                prefixIcon: Icons.credit_card,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Aadhar Number",
                hint: "Enter your Aadhar number",
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (value) {},
              ),

              const SizedBox(height: 12),

              AppDropDown(
                label: "Gender",
                items: const ['Male', 'Female', 'Other'],
                value: _gender,
                onChanged: (value) {
                  setState(() => _gender = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date of Birth'
                      : 'Date of Birth: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 24),

              // /// ✅ SAFE IMAGE PICKER
              // const ImagePickerWidget(),
              const SizedBox(height: 24),

              identityState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(onPressed: _submitForm, text: 'Save Identity'),

              const SizedBox(height: 16),

              // AppButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) =>
              //             UserBiodataCheckScreen(isAgreed: true),
              //       ),
              //     );
              //   },
              //   text: 'Go to Biodata Check Screen',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
