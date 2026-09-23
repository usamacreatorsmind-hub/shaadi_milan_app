import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/enums/enum.dart';
import '../../../../../translitration/models/bilingual_value.dart';
import '../../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../domain/states/cultural_state.dart';
import '../../../domain/states/religion_state.dart';
import '../../controllers/user_cultural_controllers.dart';

@RoutePage()
class UserCultureFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final CulturalProfile? existingCulturalProfile;
  final void Function(VoidCallback)? registerSubmit;

  const UserCultureFormScreen({super.key, required this.mode, this.existingCulturalProfile, this.registerSubmit});

  @override
  ConsumerState<UserCultureFormScreen> createState() => _UserCultureFormScreenState();
}

class _UserCultureFormScreenState extends ConsumerState<UserCultureFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _manualCasteController = TextEditingController();
  final _manualCasteEnController = TextEditingController();

  final _languagesController = TextEditingController();
  final _languagesEnController = TextEditingController();

  final List<BilingualValue> languages = [];

  BilingualValue? _selectedManglikStatus;

  final List<BilingualValue> _manglikOptions = [
    BilingualValue(hi: 'मांगलिक', en: 'Manglik'),
    BilingualValue(hi: 'आंशिक मांगलिक', en: 'Aanshik Manglik'),
    BilingualValue(hi: 'गैर-मांगलिक', en: 'Gair-Manglik'),
  ];

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);

    if (widget.mode == FormMode.edit && widget.existingCulturalProfile != null) {
      final cult = widget.existingCulturalProfile!;

      _manualCasteController.text = cult.caste.hi;
      _manualCasteEnController.text = cult.caste.en;

      languages.addAll(cult.languages);

      if (cult.manglikStatus != null) {
        _selectedManglikStatus = _manglikOptions.firstWhere((e) => e.en == cult.manglikStatus?.en, orElse: () => cult.manglikStatus!);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(religionControllerProvider.notifier).setReligion(cult.religion.en);

        ref.read(religionControllerProvider.notifier).setCaste(cult.caste.en);
      });
    }
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final religionId = ref.read(religionControllerProvider).religionId;

    BilingualValue religionBilingual = BilingualValue.empty();
    BilingualValue casteBilingual = BilingualValue.empty();

    final bilingualData = await ref.read(bilingualReligionProvider.future);
    final religionsMap = bilingualData['religions']!;

    if (religionsMap.containsKey(religionId)) {
      religionBilingual = religionsMap[religionId]!;
    }

    final manual = _manualCasteController.text.trim();
    final manualEn = _manualCasteEnController.text.trim();

    if (manualEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.pleaseSelectCaste(context))));
      return;
    }
    casteBilingual = BilingualValue(hi: manual, en: manualEn);

    List<BilingualValue> finalLanguages = List.from(languages);
    final hiLang = _languagesController.text.trim();
    final enLang = _languagesEnController.text.trim();
    if (hiLang.isNotEmpty || enLang.isNotEmpty) {
      finalLanguages.add(BilingualValue(hi: hiLang, en: enLang));
    }

    final notifier = ref.read(cultureControllerProvider.notifier);

    widget.mode == FormMode.create
        ? notifier.saveCultural(religion: religionBilingual, caste: casteBilingual, languages: finalLanguages, manglikStatus: _selectedManglikStatus)
        : notifier.updateCultural(religion: religionBilingual, caste: casteBilingual, languages: finalLanguages, manglikStatus: _selectedManglikStatus);
  }

  @override
  void dispose() {
    _manualCasteController.dispose();
    _manualCasteEnController.dispose();
    _languagesController.dispose();
    _languagesEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cultureControllerProvider);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    ref.listen(cultureControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.error(context, current.error.toString()))));
      }
      if (!current.isLoading && current.error == null && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.culturalDetailsSavedSuccessfully(context))));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: Theme.of(context).textTheme.headlineMedium,
          widget.mode == FormMode.create ? AppLabels.addCulturalDetails(context) : AppLabels.editCulturalDetails(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final religionState = ref.watch(religionControllerProvider);
                  final religionsAsyncValue = ref.watch(religionsProvider);

                  return religionsAsyncValue.when(
                    data: (religions) {
                      final selectedReligion = religions.where((r) => r.id == religionState.religionId).firstOrNull;

                      return AppDropDown<ReligionCasteModel>(
                        label: AppLabels.religion(context),
                        items: religions,
                        value: selectedReligion,
                        itemLabel: (r) => r.name,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(religionControllerProvider.notifier).setReligion(value.id);
                          }
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, _) => Text(AppLabels.error(context, err.toString())),
                  );
                },
              ),
              const SizedBox(height: 16),
              BilingualTextField(
                controller: _manualCasteController,
                englishController: _manualCasteEnController,
                label: AppLabels.caste(context),
                hint: AppLabels.specifyCasteHint(context),
                prefixIcon: Icons.edit,
              ),
              const SizedBox(height: 16),
              AppDropDown<BilingualValue>(
                label: "Manglik Status",
                items: _manglikOptions,
                value: _selectedManglikStatus,
                itemLabel: (val) => isHindi ? val.hi : val.en,
                onChanged: (val) => setState(() => _selectedManglikStatus = val),
              ),

              const SizedBox(height: 24),
              _sectionHeader(AppLabels.addKnownLanguages(context)),
              const SizedBox(height: 16),
              _extraCourseInput(),
              if (languages.isNotEmpty) ...[const SizedBox(height: 12), _extraCourseChips()],
              const SizedBox(height: 16),
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (widget.registerSubmit != null
                        ? const SizedBox.shrink()
                        : AppButton(text: AppLabels.apply(context), onPressed: _submitForm)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _extraCourseInput() {
    return Column(
      children: [
        BilingualTextField(
          controller: _languagesController,
          englishController: _languagesEnController,
          prefixIcon: Icons.language,
          label: AppLabels.addKnownLanguages(context),
          hint: AppLabels.languagesHint(context),
          validator: (v) => null,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: AppButton(
            color: Colors.red,
            width: double.infinity,
            onPressed: () {
              final hi = _languagesController.text.trim();
              final en = _languagesEnController.text.trim();
              if (hi.isEmpty && en.isEmpty) return;
              setState(() {
                languages.add(BilingualValue(hi: hi, en: en));
                _languagesController.clear();
                _languagesEnController.clear();
              });
            },
            text: AppLabels.addLanguage(context),
          ),
        ),
      ],
    );
  }

  Widget _extraCourseChips() {
    if (languages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLabels.languagesBilingual(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: languages.map((lang) {
            final isHindi = Localizations.localeOf(context).languageCode == 'hi';
            return Chip(
              label: Text(isHindi ? lang.hi : lang.en),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => setState(() => languages.remove(lang)),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
              side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
