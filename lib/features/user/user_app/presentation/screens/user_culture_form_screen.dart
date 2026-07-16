import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../core/enums/enum.dart';
import '../../domain/states/cultural_state.dart';
import '../../domain/states/religion_state.dart';
import '../controllers/user_cultural_controllers.dart';

@RoutePage()
class UserCultureFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final CulturalProfile? existingCulturalProfile;
  final void Function(VoidCallback)? registerSubmit;

  const UserCultureFormScreen({
    super.key,
    required this.mode,
    this.existingCulturalProfile,
    this.registerSubmit,
  });

  @override
  ConsumerState<UserCultureFormScreen> createState() =>
      _UserCultureFormScreenState();
}

class _UserCultureFormScreenState extends ConsumerState<UserCultureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subCasteController = TextEditingController();
  final _manualCasteController = TextEditingController();
  final _languagesController = TextEditingController();

  final List<String> langauges = [];
  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);

    if (widget.mode == FormMode.edit &&
        widget.existingCulturalProfile != null) {
      final cult = widget.existingCulturalProfile!;

      _subCasteController.text = cult.subCaste;

      // ✅ Load languages into chips
      langauges.addAll(cult.languages);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(religionControllerProvider.notifier)
            .setReligion(cult.religion);

        ref.read(religionControllerProvider.notifier).setCaste(cult.caste);
      });
    }
  }

  // @override
  // void dispose() {
  //   _subCasteController.dispose();
  //   _languagesController.dispose();
  //   super.dispose();
  // }
  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final religion = ref.read(religionControllerProvider).religion;
    var caste = ref.read(religionControllerProvider).caste;

    if (caste.toLowerCase().trim() == 'other') {
      final manual = _manualCasteController.text.trim();
      if (manual.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLabels.pleaseSelectCaste(context))));
        return;
      }
      caste = manual;
    }

    if (_languagesController.text.isNotEmpty) {
      langauges.add(_languagesController.text.trim());
    }

    ref
        .read(cultureControllerProvider.notifier)
        .saveCultural(
          religion: religion,
          caste: caste,
          subCaste: _subCasteController.text.trim(),
          languages: langauges, // ✅ FIXED
        );
  }

  @override
  void dispose() {
    _subCasteController.dispose();
    _manualCasteController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cultureControllerProvider);

    ref.listen(cultureControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      }
      if (!current.isLoading &&
          current.error == null &&
          previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLabels.culturalDetailsSavedSuccessfully(context))),
        );
      }
    });
 return  Scaffold(
      appBar: AppBar(
        title: Text(
          style: Theme.of(context).textTheme.headlineMedium,
          widget.mode == FormMode.create
              ? AppLabels.addCulturalDetails(context)
              : AppLabels.editCulturalDetails(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // create using dropdown

              /// ================= Religion =================
              Consumer(
                builder: (context, ref, child) {
                  final religionState = ref.watch(religionControllerProvider);
                  final religionsAsyncValue = ref.watch(religionsProvider);

                  return religionsAsyncValue.when(
                    data: (religions) => AppDropDown(
                      label: AppLabels.religion(context),
                      items: religions.map((r) => r.name).toList(),
                      value: religionState.religion.isEmpty
                          ? null
                          : religionState.religion,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(religionControllerProvider.notifier)
                              .setReligion(value);
                          ref
                              .read(religionControllerProvider.notifier)
                              .setCaste('');
                        }
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? AppLabels.pleaseSelectReligion(context)
                          : null,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, _) => Text('Error: $err'),
                  );
                },
              ),

              const SizedBox(height: 16),

              /// ================= Caste =================
              Consumer(
                builder: (context, ref, child) {
                  final religionState = ref.watch(religionControllerProvider);

                  if (religionState.religion.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final castesAsyncValue = ref.watch(
                    castesByReligionProvider(religionState.religion),
                  );

                  return castesAsyncValue.when(
                    data: (castes) {
                      return AppDropDown(
                        label: AppLabels.caste(context),
                        items: castes,
                        value: religionState.caste.isEmpty
                            ? null
                            : religionState.caste,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(religionControllerProvider.notifier)
                                .setCaste(value);
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? AppLabels.pleaseSelectCaste(context)
                            : null,
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, _) => Text('Error: $err'),
                  );
                },
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 12),
              // If caste is Other, show manual input
              if (ref.watch(religionControllerProvider).caste.toLowerCase() ==
                  'other')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppTextField(
                    controller: _manualCasteController,
                    label: AppLabels.specifyCaste(context),
                    hint: AppLabels.specifyCasteHint(context),
                    prefixIcon: Icons.edit,
                    iconColor: Theme.of(context).colorScheme.primary,
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    validator: (v) => v?.isEmpty == true ? AppLabels.isRequired(context) : null,
                  ),
                ),
              AppTextField(
                controller: _subCasteController,
                label: AppLabels.subCasteLabel(context),
                hint: AppLabels.subCasteHint(context),
                prefixIcon: Icons.group_add,
                validator: (v) => v?.isEmpty == true ? AppLabels.isRequired(context) : null,
                iconColor: Theme.of(context).colorScheme.primary,
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 24),
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (widget.registerSubmit != null
                        ? const SizedBox.shrink()
                        : AppButton(text: AppLabels.apply(context), onPressed: _submitForm)),

              // ========== EXTRA QUALIFICATION SECTION ==========
              _sectionHeader(AppLabels.additionalQualifications(context)),
              const SizedBox(height: 16),

              _extraCourseInput(),

              if (langauges.isNotEmpty) ...[
                const SizedBox(height: 12),
                _extraCourseChips(),
              ],
            ],
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
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _languagesController,
            prefixIcon: Icons.language,
            iconColor: Theme.of(context).colorScheme.primary,
            label: AppLabels.addKnownLanguages(context),
            hint: AppLabels.languagesHint(context),
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
              final value = _languagesController.text.trim();
              if (value.isEmpty || langauges.contains(value)) return;
              setState(() {
                langauges.add(value);
                _languagesController.clear();
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
      children: langauges.map((course) {
        return Chip(
          label: Text(course),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => setState(() => langauges.remove(course)),
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
