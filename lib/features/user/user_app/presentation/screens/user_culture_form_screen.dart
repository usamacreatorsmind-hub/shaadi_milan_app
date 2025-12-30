import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/religion_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../domain/states/cultural_state.dart';
import '../controllers/user_cultural_controllers.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/religion_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../domain/states/cultural_state.dart';
import '../controllers/user_cultural_controllers.dart';

@RoutePage()
class UserCultureFormScreen extends ConsumerStatefulWidget {
  const UserCultureFormScreen({super.key});

  @override
  ConsumerState<UserCultureFormScreen> createState() =>
      _UserCultureFormScreenState();
}

class _UserCultureFormScreenState extends ConsumerState<UserCultureFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> languages = List.empty(growable: true);

  final _subCasteController = TextEditingController();
  final _motherTongueController = TextEditingController();
  final _languagesController = TextEditingController();

  @override
  void dispose() {
    _subCasteController.dispose();
    _motherTongueController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  // ================= Submit =================
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final religionState = ref.read(religionControllerProvider);
    final religion = religionState.religion;
    final caste = religionState.caste;

    // Extra safety
    if (religion.isEmpty || caste.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select religion and caste')),
      );
      return;
    }

    final cleanedLanguages = languages
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // print all data her
    print('Religion: $religion');
    print('Caste: $caste');
    print('Sub-Caste: ${_subCasteController.text.trim()}');
    print('Mother Tongue: ${_motherTongueController.text.trim()}');
    print('Languages: $cleanedLanguages');

    ref
        .read(userCulturalControllerProvider.notifier)
        .saveCultural(
          religion: religion,
          caste: caste,
          subCaste: _subCasteController.text.trim(),
          motherTongue: _motherTongueController.text.trim(),
          languages: cleanedLanguages,
        );
  }

  @override
  Widget build(BuildContext context) {
    final culturalState = ref.watch(userCulturalControllerProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    ref.listen<CulturalState>(userCulturalControllerProvider, (
      previous,
      current,
    ) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(current.error!)));
      }

      if (current.cultural != null && previous?.cultural == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cultural profile saved successfully')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Cultural Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                  data: (castes) => AppDropDown(
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
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, _) => Text('Error: $err'),
                );
              },
            ),

            const SizedBox(height: 16),

            /// ================= Sub-Caste =================
            AppTextField(
              controller: _subCasteController,
              prefixIcon: Icons.account_tree,
              iconColor: primaryColor,
              label: "Sub-Caste",
              hint: "Enter your sub-caste",
              keyboardType: TextInputType.text,
              obscureText: false,
            ),

            const SizedBox(height: 16),

            /// ================= Mother Tongue =================
            AppTextField(
              controller: _motherTongueController,
              prefixIcon: Icons.language,
              iconColor: primaryColor,
              label: "Mother Tongue",
              hint: "Enter your mother tongue",
              keyboardType: TextInputType.text,
              obscureText: false,
            ),

            const SizedBox(height: 16),

            /// ================= Languages =================
            _languageInputRow(),

            if (languages.isNotEmpty) _languageChips(),

            const SizedBox(height: 32),

            culturalState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    onPressed: _submitForm,
                    text: "Save Cultural Profile",
                  ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ================= Language Chips =================
  Widget _languageChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: languages.map((language) {
          return Chip(
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            label: Text(language),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () {
              setState(() {
                languages.remove(language);
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

  // ================= Language Input =================
  Widget _languageInputRow() {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _languagesController,
            prefixIcon: Icons.language,
            iconColor: Theme.of(context).colorScheme.primary,
            label: 'Language',
            hint: 'e.g. Hindi, English',
            keyboardType: TextInputType.text,
            validator: (_) => null, // important
            obscureText: false,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle, size: 32),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            final value = _languagesController.text.trim();
            if (value.isEmpty || languages.contains(value)) return;

            setState(() {
              languages.add(value);
              _languagesController.clear();
            });
          },
        ),
      ],
    );
  }
}
