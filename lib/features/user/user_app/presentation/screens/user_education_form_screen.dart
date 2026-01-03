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
  final List<String> courses = List.empty(growable: true);

  // ================= Controllers =================
  final _gradCollegeCtrl = TextEditingController();
  final _gradDegreeCtrl = TextEditingController();
  final _gradPercentageCtrl = TextEditingController();
  final _gradPassingYearCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();

  @override
  void dispose() {
    _gradCollegeCtrl.dispose();
    _gradDegreeCtrl.dispose();
    _gradPercentageCtrl.dispose();
    _gradPassingYearCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
  }

  // ================= Submit =================
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final educationProfile = EducationProfile(
      education: Education(
        college: _gradCollegeCtrl.text.trim(),
        degree: _gradDegreeCtrl.text.trim(),
        percentage: double.parse(_gradPercentageCtrl.text),
        passingYear: int.parse(_gradPassingYearCtrl.text),
      ),
      extraQualification: ExtraQualification(
        qualifications: List.from(courses),
      ),
    );

    // ⚠️ Controller dependency NOT changed
    ref
        .read(userEducationControllerProvider.notifier)
        .saveEducation(educationProfile: educationProfile );
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
      appBar: AppBar(title: const Text('Education Details'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(children: [_sectionTitle('Qualification'), const Spacer()]),

                _textField(
                  controller: _gradCollegeCtrl,
                  label: 'Board / University',
                  icon: Icons.school,
                ),

                _textField(
                  controller: _gradDegreeCtrl,
                  label: 'Qualification',
                  icon: Icons.workspace_premium,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: _gradPercentageCtrl,
                        label: 'Percentage',
                        isDouble: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _yearField(
                        controller: _gradPassingYearCtrl,
                        label: 'Passing Year',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _sectionTitle('Courses'),

                _courseInputRow(),

                if (courses.isNotEmpty) _courseChips(),

                const SizedBox(height: 32),
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(onPressed: _submitForm, text: 'Save Education'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI Helpers =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppTextField(
        controller: controller,
        prefixIcon: icon,
        iconColor: Theme.of(context).colorScheme.primary,
        label: label,
        hint: label,
        keyboardType: TextInputType.text,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,

        obscureText: false,
      ),
    );
  }

  Widget _yearField({
    required TextEditingController controller,
    required String label,
    bool isDouble = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppTextField(
        obscureText: false,

        controller: controller,
        prefixIcon: Icons.date_range,
        iconColor: Theme.of(context).colorScheme.primary,
        label: label,
        hint: label,
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          if (isDouble && double.tryParse(v) == null) {
            return 'Invalid number';
          }
          if (!isDouble && int.tryParse(v) == null) {
            return 'Invalid year';
          }
          return null;
        },
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    bool isDouble = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppTextField(
        obscureText: false,

        controller: controller,
        prefixIcon: Icons.percent,
        iconColor: Theme.of(context).colorScheme.primary,
        label: label,
        hint: label,
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          if (isDouble && double.tryParse(v) == null) {
            return 'Invalid number';
          }
          if (!isDouble && int.tryParse(v) == null) {
            return 'Invalid year';
          }
          return null;
        },
      ),
    );
  }

  Widget _courseInputRow() {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _courseCtrl,
            prefixIcon: Icons.book,
            iconColor: Theme.of(context).colorScheme.primary,
            label: 'Course Name',
            hint: 'e.g. Flutter, AWS',
            keyboardType: TextInputType.text,

            // 🔥 THIS LINE STOPS VALIDATION ON SUBMIT
            validator: (_) => null,

            obscureText: false,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle, size: 32),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            final value = _courseCtrl.text.trim();
            if (value.isEmpty || courses.contains(value)) return;

            setState(() {
              courses.add(value);
              _courseCtrl.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _courseChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: courses.map((course) {
          return Chip(
            // apply border
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            // apply border radius
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            label: Text(course),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () {
              setState(() {
                courses.remove(course);
              });
            },
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.15),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      ),
    );
  }
}
