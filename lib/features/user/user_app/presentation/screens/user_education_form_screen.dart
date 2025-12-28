import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../domain/states/education_state.dart';
import '../controllers/user_education_controllers.dart';
import '../providers/providers.dart';

@RoutePage()
class UserEducationFormScreen extends ConsumerStatefulWidget {
  const UserEducationFormScreen({super.key});

  @override
  ConsumerState<UserEducationFormScreen> createState() =>
      _UserEducationFormScreenState();
}

class _UserEducationFormScreenState
    extends ConsumerState<UserEducationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // ================= Graduation =================
  final _gradCollegeCtrl = TextEditingController();
  final _gradDegreeCtrl = TextEditingController();
  final _gradPercentageCtrl = TextEditingController();
  final _gradPassingYearCtrl = TextEditingController();

  @override
  void dispose() {
    _gradCollegeCtrl.dispose();
    _gradDegreeCtrl.dispose();
    _gradPercentageCtrl.dispose();
    _gradPassingYearCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final educationProfile = EducationProfile(
      education: Education(
        college: _gradCollegeCtrl.text.trim(),
        degree: _gradDegreeCtrl.text.trim(),
        percentage: double.parse(_gradPercentageCtrl.text),
        passingYear: int.parse(_gradPassingYearCtrl.text),
      ),
    );

    ref
        .read(userEducationControllerProvider.notifier)
        .saveEducation(education: educationProfile.education!);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userEducationControllerProvider);

    ref.listen<EducationState>(userEducationControllerProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      } else if (next.education != null && prev?.education == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Education details saved successfully')),
        );
        context.router.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Education Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionTitle('Education'),
              _textField(_gradCollegeCtrl, 'College / University'),
              _textField(_gradDegreeCtrl, 'Degree'),
              _numberField(_gradPercentageCtrl, 'Percentage'),
              _numberField(_gradPassingYearCtrl, 'Passing Year'),

              const SizedBox(height: 24),
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(onPressed: _submitForm, text: 'Save Education'),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Helpers =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppTextField(
        controller: controller,
        prefixIcon: Icons.school,
        iconColor: Theme.of(context).colorScheme.primary,
        label: label,
        hint: label,
        obscureText: false,
        keyboardType: TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppTextField(
        controller: controller,
        prefixIcon: Icons.numbers,
        iconColor: Theme.of(context).colorScheme.primary,
        label: label,
        hint: label,
        obscureText: false,
        keyboardType: TextInputType.number,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}
