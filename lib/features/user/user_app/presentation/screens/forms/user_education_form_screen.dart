import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/enums/enum.dart';
import '../../../../../translitration/models/bilingual_value.dart';
import '../../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../domain/states/education_state.dart';
import '../../controllers/user_education_controllers.dart';

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
  final _collegeEnCtrl = TextEditingController();

  final _courseCtrl = TextEditingController();
  final _courseEnCtrl = TextEditingController();

  final _percentageCtrl = TextEditingController();
  final _passingYearCtrl = TextEditingController();

  final _extraCourseCtrl = TextEditingController();
  final _extraCourseEnCtrl = TextEditingController();

  final List<BilingualValue> extraCourses = [];

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
        _collegeCtrl.text = profile.education!.college.hi;
        _collegeEnCtrl.text = profile.education!.college.en;

        _courseCtrl.text = profile.education!.course.hi;
        _courseEnCtrl.text = profile.education!.course.en;

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
    _collegeEnCtrl.dispose();
    _courseCtrl.dispose();
    _courseEnCtrl.dispose();
    _percentageCtrl.dispose();
    _passingYearCtrl.dispose();
    _extraCourseCtrl.dispose();
    _extraCourseEnCtrl.dispose();
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

    List<BilingualValue> finalExtraCourses = List.from(extraCourses);
    final hiExtra = _extraCourseCtrl.text.trim();
    final enExtra = _extraCourseEnCtrl.text.trim();

    if (hiExtra.isNotEmpty || enExtra.isNotEmpty) {
      finalExtraCourses.add(BilingualValue(hi: hiExtra, en: enExtra));
    }

    final profile = EducationProfile(
      isIlletrate: false,
      education: Education(
        college: BilingualValue(
          hi: _collegeCtrl.text.trim(),
          en: _collegeEnCtrl.text.trim(),
        ),
        course: BilingualValue(
          hi: _courseCtrl.text.trim(),
          en: _courseEnCtrl.text.trim(),
        ),
        percentage: double.tryParse(_percentageCtrl.text) ?? 0.0,
        passingYear: int.tryParse(_passingYearCtrl.text) ?? 0,
      ),
      extraQualification: finalExtraCourses.isEmpty
          ? null
          : ExtraQualification(qualifications: finalExtraCourses),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLabels.error(context, next.error!))),
        );
      }

      if (next.education != null && prev?.education == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLabels.educationSavedSuccessfully(context)),
          ),
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
              ? AppLabels.educationDetails(context)
              : AppLabels.editEducation(context),
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(AppLabels.literate(context)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(AppLabels.illiterate(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (!isIlliterate) ...[
                  _sectionHeader(AppLabels.highestQualification(context)),
                  const SizedBox(height: 16),
                  BilingualTextField(
                    controller: _collegeCtrl,
                    englishController: _collegeEnCtrl,
                    prefixIcon: Icons.school,
                    label: AppLabels.collegeUniversity(context),
                    hint: AppLabels.collegeHint(context),
                    validator: (v) => v == null || v.isEmpty
                        ? AppLabels.isRequired(context)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  BilingualTextField(
                    controller: _courseCtrl,
                    englishController: _courseEnCtrl,
                    prefixIcon: Icons.book,
                    label: AppLabels.degreeCourse(context),
                    hint: AppLabels.degreeHint(context),
                    validator: (v) => v == null || v.isEmpty
                        ? AppLabels.isRequired(context)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _percentageCtrl,
                          prefixIcon: Icons.percent,
                          iconColor: Theme.of(context).colorScheme.primary,
                          label: AppLabels.percentageCGPA(context),
                          hint: AppLabels.percentageHint(context),
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null
                              ? AppLabels.mustBeNumber(context)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _passingYearCtrl,
                          prefixIcon: Icons.calendar_today,
                          iconColor: Theme.of(context).colorScheme.primary,
                          label: AppLabels.passingYear(context),
                          hint: AppLabels.yearHint(context),
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null
                              ? AppLabels.mustBeNumber(context)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(AppLabels.additionalQualifications(context)),
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
                        ? AppLabels.saveEducation(context)
                        : AppLabels.updateEducation(context),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    return Column(
      children: [
        BilingualTextField(
          controller: _extraCourseCtrl,
          englishController: _extraCourseEnCtrl,
          prefixIcon: Icons.add_box,
          label: AppLabels.addExtraQualification(context),
          hint: AppLabels.extraQualificationHint(context),
          validator: (v) => null,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: AppButton(
            color: Colors.red,
            width: double.infinity,
            onPressed: () {
              final hi = _extraCourseCtrl.text.trim();
              final en = _extraCourseEnCtrl.text.trim();
              if (hi.isEmpty && en.isEmpty) return;
              setState(() {
                extraCourses.add(BilingualValue(hi: hi, en: en));
                _extraCourseCtrl.clear();
                _extraCourseEnCtrl.clear();
              });
            },
            text: AppLabels.addQualification(context),
          ),
        ),
      ],
    );
  }

  Widget _extraCourseChips() {
    if (extraCourses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLabels.qualificationsBilingual(context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: extraCourses.map((course) {
            return Chip(
              label: Text("${course.hi} | ${course.en}"),
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
        ),
      ],
    );
  }
}
