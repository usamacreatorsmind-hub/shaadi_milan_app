import '../../../../../core/filters/home_filter_controller.dart';
import 'package:flutter/services.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../core/enums/enum.dart';
import '../../domain/states/state_city.dart';
import 'user_home_screen.dart';
import '../../domain/states/address_state.dart';
import '../controllers/user_address_controllers.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

@RoutePage()
class UserAddressFormScreen extends ConsumerStatefulWidget {
  final FormMode mode;
  final AddressProfile? existingAddressProfile;
  final void Function(VoidCallback)? registerSubmit;
  const UserAddressFormScreen({
    super.key,
    required this.mode,
    required this.existingAddressProfile,
    this.registerSubmit,
  });

  @override
  ConsumerState<UserAddressFormScreen> createState() =>
      _UserAddressFormScreenState();
}

class _UserAddressFormScreenState extends ConsumerState<UserAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _atController = TextEditingController();
  final _postController = TextEditingController();
  final _policeStationController = TextEditingController();

  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.registerSubmit?.call(_submitForm);
    if (widget.mode == FormMode.edit && widget.existingAddressProfile != null) {
      final profile = widget.existingAddressProfile!;
      _atController.text = profile.addressLine1;
      _postController.text = profile.post;
      _policeStationController.text = profile.policeStation;
      _stateController.text = profile.state;
      _districtController.text = profile.city;
      _pinController.text = profile.pincode;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeFilterProvider.notifier).updateState(profile.state);
        ref.read(homeFilterProvider.notifier).updateCity(profile.city);
      });
    }
  }

  // @override
  // void dispose() {
  //   _atController.dispose();
  //   _postController.dispose();
  //   _districtController.dispose();
  //   _stateController.dispose();
  //   _pinController.dispose();
  //   super.dispose();
  // }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(addressControllerProvider.notifier);

    if (widget.mode == FormMode.create) {
      notifier.saveAddress(
        at: _atController.text.trim(),
        post: _postController.text.trim(),
        policeStation: _policeStationController.text.trim(),
        district: _districtController.text.trim(),
        stateName: _stateController.text.trim(),
        pin: _pinController.text.trim(),
      );
    } else {
      // Update logic (using saveIdentity as upsert)
      notifier.updateAddress(
        at: _atController.text.trim(),
        post: _postController.text.trim(),
        policeStation: _policeStationController.text.trim(),
        district: _districtController.text.trim(),
        stateName: _stateController.text.trim(),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(current.error!)));
      }

      if (current.address != null && previous?.address == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Address Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                /// ================= AT =================
                AppTextField(
                  controller: _atController,
                  prefixIcon: Icons.location_on,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Place ",
                  hint: "Enter your village, street, or locality",
                  obscureText: false,
                  keyboardType: TextInputType.streetAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                /// ================= POST =================
                AppTextField(
                  controller: _postController,
                  prefixIcon: Icons.local_post_office,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Post",
                  hint: "Enter post office",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _policeStationController,
                  prefixIcon: Icons.local_police,

                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Police Station",
                  hint: "Enter Police station",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                /// ================= STATE & DISTRICT =================
                locationAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(e.toString()),
                  data: (states) {
                    final stateNames = states.map((e) => e.name).toList();

                    final selectedState = states.firstWhere(
                      (s) => s.name == location.state,
                      orElse: () => StateCityModel(name: '', cities: []),
                    );

                    _stateController.text = location.state;
                    _districtController.text = location.city;

                    return Column(
                      children: [
                        _buildDropdown(
                          context: context,
                          label: 'State',
                          value: location.state.isEmpty ? null : location.state,
                          items: stateNames,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(homeFilterProvider.notifier)
                                  .updateState(val);
                              _stateController.text = val;
                              _districtController.clear();
                            }
                          },
                        ),

                        const SizedBox(height: 12),
                        _buildDropdown(
                          context: context,
                          label: 'District',
                          value: location.city.isEmpty ? null : location.city,
                          items: selectedState.cities,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(homeFilterProvider.notifier)
                                  .updateCity(val);
                              _districtController.text = val;
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// ================= PIN =================
                AppTextField(
                  showWordCount: true,

                  maxLines: 1,
                  counterType: CounterType.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MaxLengthFormatter(max: 6),
                  ],

                  controller: _pinController,
                  prefixIcon: Icons.numbers,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "PIN Code",
                  hint: "Enter 6-digit PIN",
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'PIN required';
                    }
                    if (value.length != 6) {
                      return 'Invalid PIN';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                /// ================= SAVE =================
                addressState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (widget.registerSubmit != null
                          ? const SizedBox.shrink()
                          : AppButton(
                              onPressed: _submitForm,
                              text: 'Save Address',
                            )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= DROPDOWN BUILDER =================

  static Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
    IconData icon = Icons.arrow_drop_down_circle_outlined,
  }) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,

      value: value,

      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select ${label.toLowerCase()}',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.15),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 26,
            ),
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),

      dropdownStyleData: DropdownStyleData(
        isOverButton: true,
        maxHeight: 220,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      ),

      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),

      onChanged: onChanged,

      validator:
          validator ??
          (val) {
            if (val == null || val.isEmpty) {
              return 'Please select ${label.toLowerCase()}';
            }
            return null;
          },
    );
  }
}
