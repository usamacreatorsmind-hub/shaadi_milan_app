import 'package:auto_route/auto_route.dart';
import 'package:arvika_marriage_bureau/core/enums/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../domain/states/education_state.dart';
import '../controllers/user_education_controllers.dart';
import '../providers/providers.dart';

@RoutePage()
class UserEducationFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final EducationProfile? existingEducationProfile;
  const UserEducationFormScreen({
    super.key,
    required this.mode,
    required this.existingEducationProfile,
  });

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

  // create  a bool stateprovider  for litracey
  final isIlliterateProvider = StateProvider<bool>((ref) => false);

  // ================= Lifecycle =================

  @override
  void initState() {
    super.initState();
    if (widget.mode == FormMode.edit &&
        widget.existingEducationProfile != null) {
      final profile = widget.existingEducationProfile!;
      // Update provider after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(isIlliterateProvider.notifier).state = profile.isIlletrate;
      });

      if (!profile.isIlletrate && profile.education != null) {
        _gradCollegeCtrl.text = profile.education!.college;
        _gradDegreeCtrl.text = profile.education!.course;
        _gradPercentageCtrl.text = profile.education!.percentage.toString();
        _gradPassingYearCtrl.text = profile.education!.passingYear.toString();
      }
      if (profile.extraQualification != null) {
        courses.addAll(profile.extraQualification!.qualifications);
      }
    }
  }

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
    // check for litracy provider
    if (ref.read(isIlliterateProvider)) {
      _gradCollegeCtrl.clear();
      _gradDegreeCtrl.clear();
      _gradPercentageCtrl.clear();
      _gradPassingYearCtrl.clear();
      _courseCtrl.clear();
      courses.clear();

      final educationProfile = EducationProfile(
        isIlletrate: ref.read(isIlliterateProvider),
        education: null,
        extraQualification: null,
      );
      ref
          .read(userEducationControllerProvider.notifier)
          .saveEducation(educationProfile: educationProfile);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final educationProfile = EducationProfile(
      isIlletrate: ref.read(isIlliterateProvider),

      education: Education(
        college: _gradCollegeCtrl.text.trim(),
        course: _gradDegreeCtrl.text.trim(),
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
        .saveEducation(educationProfile: educationProfile);

    final notifier = ref.read(userEducationControllerProvider.notifier);

    if (widget.mode == FormMode.create) {
      notifier.saveEducation(educationProfile: educationProfile);
    } else {
      // Update logic (using saveEducation as upsert)
      notifier.updateEducation(educationProfile: educationProfile);
    }
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
                Center(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final isIlliterate = ref.watch(isIlliterateProvider);
                      final totalWidth =
                          MediaQuery.of(context).size.width * 0.8;

                      return SizedBox(
                        width: totalWidth,
                        child: ToggleButtons(
                          // This ensures the buttons stretch to fill the SizedBox
                          constraints: BoxConstraints(
                            minHeight: 45.0,
                            minWidth:
                                (totalWidth - 4) /
                                2, // -4 to account for standard borders
                          ),
                          isSelected: [!isIlliterate, isIlliterate],
                          onPressed: (index) {
                            ref.read(isIlliterateProvider.notifier).state =
                                (index == 1);
                          },
                          borderRadius: BorderRadius.circular(8),
                          // Visual Styling
                          selectedColor: Colors.white,
                          fillColor: Theme.of(context).primaryColor,
                          color: Theme.of(context).primaryColor,
                          children: const [
                            Text('Literate'),
                            Text('Illiterate'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // check for litracy provider
                if (ref.watch(isIlliterateProvider)) const SizedBox(height: 24),

                _litracyForm(),

                const SizedBox(height: 32),
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        onPressed: _submitForm,
                        text: ref.watch(isIlliterateProvider.notifier).state
                            ? 'Next'
                            : "Save Education",
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI Helpers =================

  Widget _litracyForm() {
    final isIlliterate = ref.watch(isIlliterateProvider);
    if (isIlliterate) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        _sectionTitle('Highest Qualification'),
        _textField(
          controller: _gradCollegeCtrl,
          label: 'College/University',
          icon: Icons.school,
        ),
        _textField(
          controller: _gradDegreeCtrl,
          label: 'Degree/Course',
          icon: Icons.book,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 18),
          child: Row(
            children: [
              Expanded(
                child: _numberField(
                  controller: _gradPercentageCtrl,
                  label: 'Percentage/CGPA',
                  isDouble: true,
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _yearField(
                  controller: _gradPassingYearCtrl,
                  label: 'Passing Year',
                ),
              ),
            ],
          ),
        ),

        _sectionTitle('Extra Qualification'),

        _courseInputRow(),

        if (courses.isNotEmpty) _courseChips(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16),

        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
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
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AppTextField(
          controller: _courseCtrl,
          prefixIcon: Icons.book,
          iconColor: Theme.of(context).colorScheme.primary,
          label: '',
          hint: 'Computer Course, Diploma, etc.',
          keyboardType: TextInputType.text,

          // 🔥 THIS LINE STOPS VALIDATION ON SUBMIT
          validator: (_) => null,

          obscureText: false,
        ),
        Positioned(
          right: 0,
          child: IconButton(
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
