import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/user_cultural_controllers.dart';
import '../../domain/states/cultural_state.dart';

@RoutePage()
class UserCultureFormScreen extends ConsumerStatefulWidget {
  const UserCultureFormScreen({super.key});

  @override
  ConsumerState<UserCultureFormScreen> createState() =>
      _UserCultureFormScreenState();
}

class _UserCultureFormScreenState extends ConsumerState<UserCultureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _religionController = TextEditingController();
  final _casteController = TextEditingController();
  final _subCasteController = TextEditingController();
  final _gothraController = TextEditingController();
  final _motherTongueController = TextEditingController();
  final _languagesController = TextEditingController();

  @override
  void dispose() {
    _religionController.dispose();
    _casteController.dispose();
    _subCasteController.dispose();
    _gothraController.dispose();
    _motherTongueController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final languages = _languagesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      ref
          .read(userCulturalControllerProvider.notifier)
          .saveCultural(
            religion: _religionController.text,
            caste: _casteController.text,
            subCaste: _subCasteController.text,
            gothra: _gothraController.text,
            motherTongue: _motherTongueController.text,
            languages: languages,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final culturalState = ref.watch(userCulturalControllerProvider);

    ref.listen<CulturalState>(userCulturalControllerProvider, (
      previous,
      current,
    ) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      } else if (current.cultural != null && previous?.cultural == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cultural profile saved successfully!')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Cultural Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppTextField(
                  controller: _religionController,
                  prefixIcon: Icons.temple_hindu,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Religion",
                  hint: "Enter your religion",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _casteController,
                  prefixIcon: Icons.temple_hindu,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Caste",
                  hint: "Enter your caste",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _subCasteController,
                  prefixIcon: Icons.temple_hindu,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Sub-Caste",
                  hint: "Enter your sub-caste",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _gothraController,
                  prefixIcon: Icons.family_restroom,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Gothra",
                  hint: "Enter your gothra",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _motherTongueController,
                  prefixIcon: Icons.language,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Mother Tongue",
                  hint: "Enter your mother tongue",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _languagesController,
                  prefixIcon: Icons.translate,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Languages",
                  hint: "Enter languages (comma separated)",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 20),
                if (culturalState.isLoading)
                  const CircularProgressIndicator()
                else
                  AppButton(
                    onPressed: _submitForm,
                    text: "  Save Cultural Profile",
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
