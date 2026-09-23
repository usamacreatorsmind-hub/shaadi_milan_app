import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../../core/enums/enum.dart';
import '../../../../../../core/filters/home_filter_controller.dart';
import '../../../../../translitration/models/bilingual_value.dart';
import '../../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../domain/states/address_state.dart';
import '../../../domain/states/state_city.dart';
import '../../controllers/user_address_controllers.dart';

@RoutePage()
class UserAddressFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final AddressProfile? existingAddressProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserAddressFormScreen({super.key, required this.mode, required this.existingAddressProfile, this.registerSubmit});

  @override
  ConsumerState<UserAddressFormScreen> createState() => _UserAddressFormScreenState();
}

class _UserAddressFormScreenState extends ConsumerState<UserAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _atController = TextEditingController();
  final _atEnController = TextEditingController();

  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinController = TextEditingController();

  final _manualDistrictHiCtrl = TextEditingController();
  final _manualDistrictEnCtrl = TextEditingController();
  bool _isManualDistrict = false;

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit && widget.existingAddressProfile != null) {
      final profile = widget.existingAddressProfile!;
      _atController.text = profile.addressLine1.hi;
      _atEnController.text = profile.addressLine1.en;

      _stateController.text = profile.state.en;
      _districtController.text = profile.city.en;
      _pinController.text = profile.pincode;

      _manualDistrictHiCtrl.text = profile.city.hi;
      _manualDistrictEnCtrl.text = profile.city.en;

      // Automatically enable manual mode if the city value doesn't match standard IDs
      if (profile.city.en.isNotEmpty) {
        _isManualDistrict = true;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeFilterProvider.notifier).updateState(profile.state.en);
        ref.read(homeFilterProvider.notifier).updateCity(profile.city.en);
      });
    }
  }

  @override
  void dispose() {
    _atController.dispose();
    _atEnController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    _manualDistrictHiCtrl.dispose();
    _manualDistrictEnCtrl.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(addressControllerProvider.notifier);
    final location = ref.read(homeFilterProvider);

    final at = BilingualValue(hi: _atController.text.trim(), en: _atEnController.text.trim());

    final bilingualData = await ref.read(bilingualLocationProvider.future);
    final statesMap = bilingualData['states']!;
    final citiesMap = bilingualData['cities']!;

    final stateBilingual = statesMap[location.state] ?? BilingualValue(hi: location.state, en: location.state);
    
    final BilingualValue cityBilingual;
    if (_isManualDistrict) {
      cityBilingual = BilingualValue(hi: _manualDistrictHiCtrl.text.trim(), en: _manualDistrictEnCtrl.text.trim());
    } else {
      cityBilingual = citiesMap[location.city] ?? BilingualValue(hi: location.city, en: location.city);
    }

    if (widget.mode == FormMode.create) {
      notifier.saveAddress(
        at: at,
        post: BilingualValue.empty(),
        policeStation: BilingualValue.empty(),
        district: cityBilingual,
        stateName: stateBilingual,
        pin: _pinController.text.trim(),
      );
    } else {
      notifier.updateAddress(
        at: at,
        post: BilingualValue.empty(),
        policeStation: BilingualValue.empty(),
        district: cityBilingual,
        stateName: stateBilingual,
        pin: _pinController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressControllerProvider);

    final location = ref.watch(homeFilterProvider);
    final locationAsync = ref.watch(locationJsonProvider);

    ref.listen<AddressState>(addressControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.error(context, current.error!))));
      }

      if (current.address != null && previous?.address == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.addressSavedSuccessfully(context))));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.addressDetails(context), style: Theme.of(context).textTheme.headlineMedium)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                BilingualTextField(
                  controller: _atController,
                  englishController: _atEnController,
                  prefixIcon: Icons.location_on,
                  label: AppLabels.place(context),
                  hint: AppLabels.placeHint(context),
                ),
                const SizedBox(height: 16),
                locationAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(e.toString()),
                  data: (states) {
                    final selectedState = states.where((s) => s.name == location.state).firstOrNull;

                    final selectedCity = selectedState?.cities.where((c) => c.id == location.city || c.name == location.city).firstOrNull;

                    return Column(
                      children: [
                        AppDropDown<StateCityModel>(
                          label: AppLabels.state(context),
                          items: states,
                          value: selectedState,
                          itemLabel: (s) => s.name,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(homeFilterProvider.notifier).updateState(val.name);
                              _stateController.text = val.name;
                              _districtController.clear();
                            }
                          },
                        ),

                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text("Type District Manually"),
                          value: _isManualDistrict,
                          onChanged: (val) {
                            setState(() {
                              _isManualDistrict = val ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),
                        if (_isManualDistrict) ...[
                          BilingualTextField(
                            controller: _manualDistrictHiCtrl,
                            englishController: _manualDistrictEnCtrl,
                            prefixIcon: Icons.map_outlined,
                            label: "District",
                            hint: "Enter district name",
                          ),
                        ] else ...[
                          AppDropDown<CityModel>(
                            label: AppLabels.districtLabel(context),
                            items: selectedState?.cities ?? [],
                            value: selectedCity,
                            itemLabel: (c) => c.name,
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(homeFilterProvider.notifier).updateCity(val.id);
                                _districtController.text = val.id;
                              }
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  showWordCount: true,
                  maxLines: 1,
                  counterType: CounterType.characters,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, MaxLengthFormatter(max: 6)],
                  controller: _pinController,
                  prefixIcon: Icons.numbers,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: AppLabels.pinCodeLabel(context),
                  hint: AppLabels.pinCodeHint(context),
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length != 6) {
                      return AppLabels.invalidPinCode(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                addressState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (widget.registerSubmit != null
                          ? const SizedBox.shrink()
                          : AppButton(onPressed: _submitForm, text: AppLabels.saveAddress(context))),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
