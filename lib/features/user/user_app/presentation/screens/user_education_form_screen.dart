import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../../core/enums/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../domain/states/education_state.dart';
import '../controllers/user_education_controllers.dart';

@RoutePage()
class UserEducationFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final EducationProfile? existingEducationProfile;
  final void Function(VoidCallback)? registerSubmit;

  const UserEducationFormScreen({
    super.key,
    required this.mode,
    this.existingEducationProfile,
    this.registerSubmit,
  });

  @override
  ConsumerState<UserEducationFormScreen> createState() =>
      _UserEducationFormScreenState();
}

class _UserEducationFormScreenState
    extends ConsumerState<UserEducationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- Controllers ----------------
  final _collegeCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _percentageCtrl = TextEditingController();
  final _passingYearCtrl = TextEditingController();
  final _extraCourseCtrl = TextEditingController();

  final List<String> extraCourses = [];

  final isIlliterateProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);

    if (widget.mode == FormMode.edit &&
        widget.existingEducationProfile != null) {
      final profile = widget.existingEducationProfile!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(isIlliterateProvider.notifier).state = profile.isIlletrate;
      });

      if (!profile.isIlletrate && profile.education != null) {
        _collegeCtrl.text = profile.education!.college;
        _courseCtrl.text = profile.education!.course;
        _percentageCtrl.text = profile.education!.percentage.toString();
        _passingYearCtrl.text = profile.education!.passingYear.toString();
      }

      if (profile.extraQualification != null) {
        extraCourses.addAll(profile.extraQualification!.qualifications);
      }
    }
  }

  @override
  void dispose() {
    _collegeCtrl.dispose();
    _courseCtrl.dispose();
    _percentageCtrl.dispose();
    _passingYearCtrl.dispose();
    _extraCourseCtrl.dispose();
    super.dispose();
  }

  // ---------------- SUBMIT ----------------
  void _submitForm() {
    final isIlliterate = ref.read(isIlliterateProvider);

    if (isIlliterate) {
      final profile = EducationProfile(
        isIlletrate: true,
        education: null,
        extraQualification: null,
      );

      ref
          .read(userEducationControllerProvider.notifier)
          .saveEducation(educationProfile: profile);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final profile = EducationProfile(
      isIlletrate: false,
      education: Education(
        college: _collegeCtrl.text.trim(),
        course: _courseCtrl.text.trim(),
        percentage: double.parse(_percentageCtrl.text),
        passingYear: int.parse(_passingYearCtrl.text),
      ),
      extraQualification: ExtraQualification(
        qualifications: List.from(extraCourses),
      ),
    );

    final notifier = ref.read(userEducationControllerProvider.notifier);

    widget.mode == FormMode.create
        ? notifier.saveEducation(educationProfile: profile)
        : notifier.updateEducation(educationProfile: profile);
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userEducationControllerProvider);

    ref.listen<EducationState>(userEducationControllerProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }

      if (next.education != null && prev?.education == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Education saved successfully')),
        );
      }
    });

    final isIlliterate = ref.watch(isIlliterateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.mode == FormMode.create
              ? 'Education Details'
              : 'Edit Education',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // ========== LITERACY TOGGLE ==========
                ToggleButtons(
                  constraints: BoxConstraints(
                    minHeight: 40,
                    minWidth: (MediaQuery.of(context).size.width - 48) / 2,
                  ),

                  isSelected: [!isIlliterate, isIlliterate],
                  onPressed: (i) =>
                      ref.read(isIlliterateProvider.notifier).state = i == 1,
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: Theme.of(context).colorScheme.primary,
                  color: Theme.of(context).colorScheme.primary,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Literate'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Illiterate'),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                if (!isIlliterate) ...[
                  // ========== QUALIFICATION SECTION ==========
                  _sectionHeader('Highest Qualification'),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _collegeCtrl,
                    prefixIcon: Icons.school,
                    iconColor: Theme.of(context).colorScheme.primary,
                    label: 'College / University',
                    hint: 'Enter college or university name',
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  AppTextField(
                    controller: _courseCtrl,
                    prefixIcon: Icons.book,
                    iconColor: Theme.of(context).colorScheme.primary,
                    label: 'Degree / Course',
                    hint: 'Enter degree or course name',
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _percentageCtrl,
                          prefixIcon: Icons.percent,
                          iconColor: Theme.of(context).colorScheme.primary,
                          label: 'Percentage / CGPA',
                          hint: 'e.g., 75.5',
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null
                              ? 'Invalid number'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _passingYearCtrl,
                          prefixIcon: Icons.calendar_today,
                          iconColor: Theme.of(context).colorScheme.primary,
                          label: 'Passing Year',
                          hint: 'e.g., 2023',
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null
                              ? 'Invalid year'
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ========== EXTRA QUALIFICATION SECTION ==========
                  _sectionHeader('Additional Qualifications'),
                  const SizedBox(height: 16),

                  _extraCourseInput(),

                  if (extraCourses.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _extraCourseChips(),
                  ],
                ],

                const SizedBox(height: 32),

                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (widget.registerSubmit == null)
                  AppButton(
                    onPressed: _submitForm,
                    text: widget.mode == FormMode.create
                        ? 'Save Education'
                        : 'Update Education',
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== UI HELPERS ==========

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _extraCourseInput() {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _extraCourseCtrl,
            prefixIcon: Icons.add_box,
            iconColor: Theme.of(context).colorScheme.primary,
            label: 'Add Extra Qualification',
            hint: 'e.g., Computer Course, Diploma',
            obscureText: false,
            keyboardType: TextInputType.text,
            validator: (_) => null,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          child: IconButton(
            icon: Icon(
              Icons.add_circle,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              final value = _extraCourseCtrl.text.trim();
              if (value.isEmpty || extraCourses.contains(value)) return;
              setState(() {
                extraCourses.add(value);
                _extraCourseCtrl.clear();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _extraCourseChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: extraCourses.map((course) {
        return Chip(
          label: Text(course),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => setState(() => extraCourses.remove(course)),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }
}
