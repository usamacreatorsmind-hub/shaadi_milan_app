import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';

import '../../domain/states/lifestyle_state.dart';
import '../controllers/user_lifestyle_controllers.dart';
import '../providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_route/auto_route.dart';

@RoutePage()
class UserLifestyleFormScreen extends ConsumerStatefulWidget {
  const UserLifestyleFormScreen({super.key});

  @override
  ConsumerState<UserLifestyleFormScreen> createState() =>
      _UserLifestyleFormScreenState();
}

class _UserLifestyleFormScreenState
    extends ConsumerState<UserLifestyleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _maritalStatus;
  bool _smoking = false;
  bool _drinking = false;
  String? _foodHabit;
  final _hobbiesController = TextEditingController();

  @override
  void dispose() {
    _hobbiesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_maritalStatus == null || _foodHabit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select marital status and food habit'),
          ),
        );
        return;
      }

      ref
          .read(userLifestyleControllerProvider.notifier)
          .saveLifestyle(
            maritalStatus: _maritalStatus!,
            smoking: _smoking,
            drinking: _drinking,
            foodHabit: _foodHabit!,
            hobbies: _hobbiesController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lifestyleState = ref.watch(userLifestyleControllerProvider);

    ref.listen<LifestyleState>(userLifestyleControllerProvider, (
      previous,
      current,
    ) {
      if (current.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${current.error}')));
      } else if (current.lifestyle != null && previous?.lifestyle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lifestyle profile saved successfully!'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Lifestyle Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppDropDown(
                label: "Marital Status",
                items: const [
                  'Never Married',
                  'Divorced',
                  'Widowed',
                  'Annulled',
                ],
                value: _maritalStatus,
                onChanged: (value) {
                  setState(() => _maritalStatus = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select marital status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              AppDropDown(
                label: "Food Habit",
                items: const ['Vegetarian', 'Non-Vegetarian', 'Eggetarian'],
                value: _foodHabit,
                onChanged: (value) {
                  setState(() => _foodHabit = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select food habit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _hobbiesController,
                prefixIcon: Icons.sports_handball,
                iconColor: Theme.of(context).colorScheme.primary,
                label: "Hobbies",
                hint: "Enter your hobbies (comma separated)",
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              AppSwitch(
                title: 'Smoking',
                value: _smoking,
                onChanged: (bool value) {
                  setState(() {
                    _smoking = value;
                  });
                },
              ),
              AppSwitch(
                title: 'Drinking',
                value: _drinking,
                onChanged: (bool value) {
                  setState(() {
                    _drinking = value;
                  });
                },
              ),

              const SizedBox(height: 20),
              if (lifestyleState.isLoading)
                const CircularProgressIndicator()
              else
                AppButton(onPressed: _submitForm, text: 'Save Lifestyle'),
            ],
          ),
        ),
      ),
    );
  }
}
