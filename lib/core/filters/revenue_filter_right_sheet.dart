import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/user/user_app/domain/states/religion_state.dart';
import '../../features/user/user_app/domain/states/state_city.dart';
import 'revenue_filter_controller.dart';

class RevenueFilterRightSheet extends ConsumerWidget {
  const RevenueFilterRightSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(revenueFilterProvider);
    final locationAsync = ref.watch(locationJsonProvider);
    final religionsAsync = ref.watch(religionsProvider);

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Revenue',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(revenueFilterProvider.notifier).reset();
                        },
                        child: const Text('Reset'),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // datepivker for start and end

                      // ================= DATE RANGE SECTION =================
                      const Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              context: context,
                              title: 'Start Date',
                              selectedDate: filter.startDate,
                              onChanged: (date) {
                                ref
                                    .read(revenueFilterProvider.notifier)
                                    .updateStartDate(date);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDatePicker(
                              context: context,
                              title: 'End Date',
                              selectedDate: filter.endDate,

                              onChanged: (date) {
                                ref
                                    .read(revenueFilterProvider.notifier)
                                    .updateEndDate(date);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ================= LOCATION SECTION =================
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      locationAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                        data: (states) {
                          /// All state names from JSON
                          final stateNames = states.map((e) => e.name).toList();

                          /// Selected state object
                          final selectedState = states.firstWhere(
                            (s) => s.name == filter.state,
                            orElse: () => StateCityModel(name: '', cities: []),
                          );

                          return Column(
                            children: [
                              _buildDropdown(
                                title: 'State',
                                value: filter.state.isEmpty
                                    ? null
                                    : filter.state,
                                items: stateNames,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateState(val);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                title: 'City',
                                value: filter.city.isEmpty ? null : filter.city,
                                items: selectedState.cities,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateCity(val);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ================= RELIGION SECTION =================
                      const Text(
                        'Cultural',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      religionsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                        data: (religions) {
                          final religionNames = religions
                              .map((r) => r.name)
                              .toList();

                          final selectedReligion = religions.firstWhere(
                            (r) => r.name == filter.religion,
                            orElse: () =>
                                ReligionModel(id: '', name: '', castes: []),
                          );

                          return Column(
                            children: [
                              _buildDropdown(
                                title: 'Religion',
                                value: filter.religion.isEmpty
                                    ? null
                                    : filter.religion,
                                items: religionNames,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateReligion(val);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                title: 'Caste',
                                value: filter.caste.isEmpty
                                    ? null
                                    : filter.caste,
                                items: selectedReligion.castes,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateCaste(val);
                                  }
                                },
                              ),

                              // ================= GENDER SECTION =================
                              const SizedBox(height: 24),

                              const SizedBox(height: 8),
                              _buildDropdown(
                                title: 'Gender',
                                value: filter.gender.isEmpty
                                    ? null
                                    : filter.gender,
                                items: const ['Male', 'Female'],
                                onChanged: (val) {
                                  ref
                                      .read(revenueFilterProvider.notifier)
                                      .updateGender(val);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= DROPDOWN BUILDER =================
  static Widget _buildDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required String title,
    DateTime? selectedDate,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: selectedDate == null
                ? ''
                : DateFormat('dd/MM/yyyy').format(selectedDate),
          ),
          decoration: InputDecoration(
            hintText: 'Select $title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null && picked != selectedDate) {
              onChanged(picked);
            }
          },
        ),
      ],
    );
  }
}
