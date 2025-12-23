import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';

import '../../domain/states/address_state.dart';
import '../controllers/user_address_controllers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class UserAddressFormScreen extends ConsumerStatefulWidget {
  const UserAddressFormScreen({super.key});

  @override
  ConsumerState<UserAddressFormScreen> createState() =>
      _UserAddressScreenState();
}

class _UserAddressScreenState extends ConsumerState<UserAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _atController = TextEditingController();
  final _postController = TextEditingController();
  final _psController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _atController.dispose();
    _postController.dispose();
    _psController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(addressControllerProvider.notifier)
          .saveAddress(
            at: _atController.text,
            post: _postController.text,
            ps: _psController.text,
            district: _districtController.text,
            stateName: _stateController.text,
            pin: _pinController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressControllerProvider);

    ref.listen<AddressState>(addressControllerProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      } else if (current.address != null && previous?.address == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully!')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Address Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _atController,
                  prefixIcon: Icons.location_on,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "At",
                  hint: "Enter your address (At)",
                  obscureText: false,
                  keyboardType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _postController,
                  prefixIcon: Icons.local_post_office,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "Post",
                  hint: "Enter your post office",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _psController,
                  prefixIcon: Icons.local_police,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "PS",
                  hint: "Enter your police station",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _districtController,
                  prefixIcon: Icons.location_city,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "District",
                  hint: "Enter your district",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _stateController,
                  prefixIcon: Icons.map,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "State",
                  hint: "Enter your state",
                  obscureText: false,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _pinController,
                  prefixIcon: Icons.numbers,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: "PIN",
                  hint: "Enter your PIN code",
                  obscureText: false,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),
                if (addressState.isLoading)
                  const CircularProgressIndicator()
                else
                  AppButton(onPressed: _submitForm, text: 'Save Address'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
