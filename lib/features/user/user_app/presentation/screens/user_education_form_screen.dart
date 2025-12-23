import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';
import '../../domain/states/education_state.dart';
import '../controllers/user_education_controllers.dart';
import '../providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_route/auto_route.dart';

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
  final _highestQualificationController = TextEditingController();
  final _collegeUniversityController = TextEditingController();
  final _degreeController = TextEditingController();
  final _majorSubjectController = TextEditingController();

  @override
  void dispose() {
    _highestQualificationController.dispose();
    _collegeUniversityController.dispose();
    _degreeController.dispose();
    _majorSubjectController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(userEducationControllerProvider.notifier)
          .saveEducation(
            highestQualification: _highestQualificationController.text,
            college: '',
            degree: '',
            occupation: _majorSubjectController.text,
            annualIncome: 'Not provided',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(userEducationControllerProvider);

    ref.listen<EducationState>(userEducationControllerProvider, (
      previous,
      next,
    ) {
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      } else if (next.education != null && previous?.education == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Education details saved successfully!'),
          ),
        );
        context.router.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Education Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                controller: _highestQualificationController,
                prefixIcon: Icons.school,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Highest Qualification",
                hint: "Enter your highest qualification",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16.0),

              AppTextField(
                controller: _collegeUniversityController,
                prefixIcon: Icons.school,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "College/University",
                hint: "Enter your college or university",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16.0),

              AppTextField(
                controller: _degreeController,
                prefixIcon: Icons.book,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Degree",
                hint: "Enter your degree",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16.0),

              AppTextField(
                controller: _majorSubjectController,
                prefixIcon: Icons.subject,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Major Subject",
                hint: "Enter your major subject",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16.0),
              educationState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(onPressed: _submitForm, text: 'Save Education'),
            ],
          ),
        ),
      ),
    );
  }
}
