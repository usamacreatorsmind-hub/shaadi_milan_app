import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';

import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/enums/enum.dart';
import '../../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../domain/states/physical_state.dart';
import '../../controllers/user_physical_controllers.dart';

@RoutePage()
class UserPhysicalFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final PhysicalProfile? existingPhysicalProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserPhysicalFormScreen({super.key, required this.mode, required this.existingPhysicalProfile, this.registerSubmit});

  @override
  ConsumerState<UserPhysicalFormScreen> createState() => _UserPhysicalFormScreenState();
}

class _UserPhysicalFormScreenState extends ConsumerState<UserPhysicalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _disabilityDetailsController = TextEditingController();
  final _disabilityDetailsEnController = TextEditingController();

  int? _selectedHeight;
  int? _selectedWeight;
  BilingualValue? _selectedBodyType;
  BilingualValue? _selectedComplexion;

  bool _physicallyChallenged = false;

  final List<int> _heightOptions = List.generate(151, (index) => index + 100);
  final List<int> _weightOptions = List.generate(121, (index) => index + 30);

  final Map<String, BilingualValue> _bodyTypeOptions = {
    'Slim': BilingualValue(hi: 'दुबला', en: 'Slim'),
    'Athletic': BilingualValue(hi: 'एथलेटिक', en: 'Athletic'),
    'Average': BilingualValue(hi: 'औसत', en: 'Average'),
    'Heavy': BilingualValue(hi: 'भारी', en: 'Heavy'),
    'Muscular': BilingualValue(hi: 'पेशी', en: 'Muscular'),
    'Obese': BilingualValue(hi: 'मोटापा', en: 'Obese'),
  };

  final Map<String, BilingualValue> _complexionOptions = {
    'Very Fair': BilingualValue(hi: 'बहुत गोरा', en: 'Very Fair'),
    'Fair': BilingualValue(hi: 'गोरा', en: 'Fair'),
    'Wheatish': BilingualValue(hi: 'गेहुँआ', en: 'Wheatish'),
    'Dark': BilingualValue(hi: 'सांवला', en: 'Dark'),
    'Brown': BilingualValue(hi: 'भूरा', en: 'Brown'),
    'Dusky': BilingualValue(hi: 'सांवला-सलोना', en: 'Dusky'),
    'Dark Brown': BilingualValue(hi: 'गहरा भूरा', en: 'Dark Brown'),
    'Black': BilingualValue(hi: 'काला', en: 'Black'),
  };

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit && widget.existingPhysicalProfile != null) {
      final profile = widget.existingPhysicalProfile!;
      _selectedHeight = profile.height.round();
      _selectedWeight = profile.weight.round();

      _selectedBodyType = _bodyTypeOptions.values.firstWhere((e) => e.en == profile.bodyType.en, orElse: () => profile.bodyType);

      _selectedComplexion = _complexionOptions.values.firstWhere((e) => e.en == profile.complexion.en, orElse: () => profile.complexion);

      _physicallyChallenged = profile.physicallyChallenged;
      _disabilityDetailsController.text = profile.disabilityDetails?.hi ?? '';
      _disabilityDetailsEnController.text = profile.disabilityDetails?.en ?? '';
    }
  }

  @override
  void dispose() {
    _disabilityDetailsController.dispose();
    _disabilityDetailsEnController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final notifier = ref.read(userPhysicalControllerProvider.notifier);

    final disability = _physicallyChallenged
        ? BilingualValue(hi: _disabilityDetailsController.text, en: _disabilityDetailsEnController.text)
        : null;

    final height = _selectedHeight?.toDouble() ?? 160.0;
    final weight = _selectedWeight?.toDouble() ?? 60.0;
    final bodyType = _selectedBodyType ?? _bodyTypeOptions['Average']!;
    final complexion = _selectedComplexion ?? _complexionOptions['Wheatish']!;

    if (widget.mode == FormMode.create) {
      notifier.savePhysicals(
        height: height,
        weight: weight,
        bodyType: bodyType,
        complexion: complexion,
        physicallyChallenged: _physicallyChallenged,
        disabilityDetails: disability,
      );
    } else {
      notifier.updatePhysicals(
        height: height,
        weight: weight,
        bodyType: bodyType,
        complexion: complexion,
        physicallyChallenged: _physicallyChallenged,
        disabilityDetails: disability,
      );
    }
  }

  String _formatHeight(int cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return '$cm cm ($feet\'$inches")';
  }

  @override
  Widget build(BuildContext context) {
    final physicalState = ref.watch(userPhysicalControllerProvider);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    ref.listen<PhysicalState>(userPhysicalControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.error(context, current.error.toString()))));
      } else if (current.physical != null && !physicalState.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.physicalProfileSavedSuccessfully(context))));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.physicalDetails(context), style: Theme.of(context).textTheme.headlineMedium)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppDropDown<int>(
                label: AppLabels.heightCm(context),
                items: _heightOptions,
                value: _selectedHeight,
                itemLabel: (cm) => _formatHeight(cm),
                onChanged: (value) {
                  setState(() => _selectedHeight = value);
                },
              ),
              const SizedBox(height: 16),
              AppDropDown<int>(
                label: AppLabels.weightKg(context),
                items: _weightOptions,
                value: _selectedWeight,
                itemLabel: (kg) => '$kg kg',
                onChanged: (value) {
                  setState(() => _selectedWeight = value);
                },
              ),
              const SizedBox(height: 16),
              AppDropDown<BilingualValue>(
                label: AppLabels.selectBodyType(context),
                items: _bodyTypeOptions.values.toList(),
                value: _selectedBodyType,
                itemLabel: (type) => isHindi ? type.hi : type.en,
                onChanged: (value) {
                  setState(() => _selectedBodyType = value);
                },
              ),
              const SizedBox(height: 16),
              AppDropDown<BilingualValue>(
                label: AppLabels.selectComplexion(context),
                items: _complexionOptions.values.toList(),
                value: _selectedComplexion,
                itemLabel: (comp) => isHindi ? comp.hi : comp.en,
                onChanged: (value) {
                  setState(() => _selectedComplexion = value);
                },
              ),
              const SizedBox(height: 16),
              AppSwitch(
                title: AppLabels.physicallyChallenged(context),
                value: _physicallyChallenged,
                onChanged: (value) {
                  setState(() {
                    _physicallyChallenged = value;
                  });
                },
              ),
              if (_physicallyChallenged) ...[
                const SizedBox(height: 16),
                BilingualTextField(
                  controller: _disabilityDetailsController,
                  englishController: _disabilityDetailsEnController,
                  prefixIcon: Icons.accessible,
                  label: AppLabels.disabilityDetails(context),
                  hint: AppLabels.disabilityDetailsHint(context),
                  validator: (v) => v == null || v.isEmpty ? AppLabels.pleaseEnter(context) : null,
                ),
              ],
              const SizedBox(height: 20),
              if (physicalState.isLoading)
                const CircularProgressIndicator()
              else
                (widget.registerSubmit != null
                    ? const SizedBox.shrink()
                    : AppButton(onPressed: _submitForm, text: AppLabels.physicalProfile(context))),
            ],
          ),
        ),
      ),
    );
  }

  int totalInchesToFeet(int inches) {
    return inches ~/ 12;
  }
}
