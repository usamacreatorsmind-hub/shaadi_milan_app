import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

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
                  Text(
                    AppLabels.filterRevenue(context),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(revenueFilterProvider.notifier).reset();
                        },
                        child: Text(AppLabels.reset(context)),
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
                      Text(
                        AppLabels.dateRange(context),
                        style: const TextStyle(
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
                              title: AppLabels.startDate(context),
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
                              title: AppLabels.endDate(context),
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
                      Text(
                        AppLabels.location(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      locationAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('${AppLabels.errorOccurred(context)}: $e'),
                        data: (states) {
                          /// Selected state object
                          final selectedState = states
                              .where((s) => s.name == filter.state)
                              .firstOrNull;

                          final selectedCity = selectedState?.cities
                              .where((c) => c.id == filter.city || c.name == filter.city)
                              .firstOrNull;

                          return Column(
                            children: [
                              _buildDropdown<StateCityModel>(
                                title: AppLabels.state(context),
                                value: selectedState,
                                items: states,
                                itemLabel: (s) => s.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateState(val.name);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown<CityModel>(
                                title: AppLabels.city(context),
                                value: selectedCity,
                                items: selectedState?.cities ?? [],
                                itemLabel: (c) => c.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateCity(val.id);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ================= RELIGION SECTION =================
                      Text(
                        AppLabels.cultural(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      religionsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('${AppLabels.errorOccurred(context)}: $e'),
                        data: (religions) {
                          final selectedReligion = religions
                              .where((r) => r.id == filter.religion || r.name == filter.religion)
                              .firstOrNull;

                          final selectedCaste = selectedReligion?.castes
                              .where((c) => c.id == filter.caste || c.name == filter.caste)
                              .firstOrNull;

                          return Column(
                            children: [
                              _buildDropdown<ReligionCasteModel>(
                                title: AppLabels.religion(context),
                                value: selectedReligion,
                                items: religions,
                                itemLabel: (r) => r.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateReligion(val.id);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown<CasteModel>(
                                title: AppLabels.caste(context),
                                value: selectedCaste,
                                items: selectedReligion?.castes ?? [],
                                itemLabel: (c) => c.name,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateCaste(val.id);
                                  }
                                },
                              ),

                              // ================= GENDER SECTION =================
                              const SizedBox(height: 24),

                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                title: AppLabels.gender(context),
                                value: filter.gender.isEmpty
                                    ? null
                                    : filter.gender,
                                items: [AppLabels.male(context), AppLabels.female(context)],
                                itemLabel: (g) => g,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(revenueFilterProvider.notifier)
                                        .updateGender(val);
                                  }
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
                  child: Text(AppLabels.applyFilters(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= DROPDOWN BUILDER =================
  static Widget _buildDropdown<T>({
    required String title,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
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
            hintText: '${AppLabels.select(context)} $title',
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
