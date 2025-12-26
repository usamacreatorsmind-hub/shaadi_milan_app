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
    if (!_formKey.currentState!.validate()) return;

    final languages = _languagesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    ref
        .read(userCulturalControllerProvider.notifier)
        .saveCultural(
          religion: _religionController.text.trim(),
          caste: _casteController.text.trim(),
          subCaste: _subCasteController.text.trim(),
          gothra: _gothraController.text.trim(),
          motherTongue: _motherTongueController.text.trim(),
          languages: languages,
        );
  }

  @override
  Widget build(BuildContext context) {
    final culturalState = ref.watch(userCulturalControllerProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // ✅ ref.listen MUST stay in build
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
            AppTextField(
              controller: _religionController,
              prefixIcon: Icons.temple_hindu,
              iconColor: primaryColor,
              label: "Religion",
              hint: "Enter your religion",
              obscureText: false,
              keyboardType: TextInputType.text,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Religion is required' : null,
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _casteController,
              prefixIcon: Icons.account_tree_outlined,
              iconColor: primaryColor,
              label: "Caste",
              hint: "Enter your caste",
              obscureText: false,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _subCasteController,
              prefixIcon: Icons.account_tree,
              iconColor: primaryColor,
              label: "Sub-Caste",
              hint: "Enter your sub-caste",
              obscureText: false,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _gothraController,
              prefixIcon: Icons.family_restroom,
              iconColor: primaryColor,
              label: "Gothra",
              hint: "Enter your gothra",
              obscureText: false,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _motherTongueController,
              prefixIcon: Icons.language,
              iconColor: primaryColor,
              label: "Mother Tongue",
              hint: "Enter your mother tongue",
              obscureText: false,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _languagesController,
              prefixIcon: Icons.translate,
              iconColor: primaryColor,
              label: "Languages Known",
              hint: "Hindi, English, Urdu",
              obscureText: false,
              keyboardType: TextInputType.text,
            ),

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
}
