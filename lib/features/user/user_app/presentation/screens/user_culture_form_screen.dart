import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit &&
        widget.existingCulturalProfile != null) {
      final cult = widget.existingCulturalProfile!;
      _subCasteController.text = cult.subCaste;
      _languagesController.text = cult.languages.join(", ");

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
    if (!_formKey.currentState!.validate()) return;

    final religion = ref.read(religionControllerProvider).religion;
    var caste = ref.read(religionControllerProvider).caste;

    // If user selected 'Other', take manual input
    if (caste.toLowerCase() == 'other') {
      final manual = _manualCasteController.text.trim();
      if (manual.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter caste')));
        return;
      }
      caste = manual;
    }

    ref
        .read(cultureControllerProvider.notifier)
        .saveCultural(
          religion: religion,
          caste: caste,
          subCaste: _subCasteController.text.trim(),
          languages: _languagesController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
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
          const SnackBar(content: Text('Cultural details saved successfully')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: Theme.of(context).textTheme.headlineMedium,
          widget.mode == FormMode.create
              ? 'Add Cultural Details'
              : 'Edit Cultural Details',
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
                      label: "Religion",
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
                          ? 'Please select a religion'
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
                        label: "Caste",
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
                            ? 'Please select a caste'
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
                    label: 'Specify Caste',
                    hint: 'Enter your caste',
                    prefixIcon: Icons.edit,
                    iconColor: Theme.of(context).colorScheme.primary,
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              AppTextField(
                controller: _subCasteController,
                label: "Sub-Caste",
                hint: "Enter sub-caste",
                prefixIcon: Icons.group_add,
                validator: (v) => v?.isEmpty == true ? "Required" : null,
                iconColor: Theme.of(context).colorScheme.primary,
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _languagesController,
                label: "Languages Known",
                hint: "Enter languages separated by commas",
                prefixIcon: Icons.language,
                validator: (v) => v?.isEmpty == true ? "Required" : null,
                iconColor: Theme.of(context).colorScheme.primary,
                obscureText: false,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 24),
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (widget.registerSubmit != null
                        ? const SizedBox.shrink()
                        : AppButton(text: "Save", onPressed: _submitForm)),
            ],
          ),
        ),
      ),
    );
  }
}
