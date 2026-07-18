import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

import '../../features/agent/agent_app/presentation/screens/agent_users_screen.dart';
import '../../features/user/user_app/domain/states/state_city.dart';
import '../../features/user/user_app/domain/states/religion_state.dart';

/// =====================================================
/// CLIENT FILTER RIGHT SHEET
/// Opens as a right-slide panel (same as FilterRightSheet
/// in the user home screen) for the Agent Clients tab.
/// =====================================================

/// Helper — open the sheet with the same slide-from-right
/// animation used on the user home screen.
void showClientFilterSheet(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppLabels.filterClients(context),
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => const ClientFilterRightSheet(),
    transitionBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}

class ClientFilterRightSheet extends ConsumerWidget {
  const ClientFilterRightSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(clientFilterProvider);
    final notifier = ref.read(clientFilterProvider.notifier);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: screenWidth * 0.85,
          height: double.infinity,
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── HEADER ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: theme.primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLabels.filterClients(context),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (!filter.isDefault)
                            TextButton(
                              onPressed: () => notifier.reset(),
                              child: Text(
                                AppLabels.reset(context),
                                style: TextStyle(color: theme.primaryColor),
                              ),
                            ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Active filter count badge
                  if (filter.activeFilterCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${filter.activeFilterCount} ${filter.activeFilterCount > 1 ? AppLabels.filters(context) : AppLabels.filter(context)} ${AppLabels.active(context)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  const Divider(),

                  // ─── SCROLLABLE CONTENT ─────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ══ LOCATION ═════════════════════════
                          _sectionLabel(AppLabels.location(context)),
                          const SizedBox(height: 10),
                          _LocationSection(
                            selectedState: filter.state,
                            selectedCity: filter.city,
                            onStateChanged: (v) {
                              notifier.setFilterState(v ?? '');
                            },
                            onCityChanged: (v) {
                              notifier.setCity(v ?? '');
                            },
                          ),
                          const SizedBox(height: 24),

                          // ══ RELIGION & CASTE ═════════════════
                          _sectionLabel(AppLabels.religionAndCaste(context)),
                          const SizedBox(height: 10),
                          _CulturalSection(
                            selectedReligion: filter.religion,
                            selectedCaste: filter.caste,
                            onReligionChanged: (v) {
                              notifier.setReligion(v ?? '');
                            },
                            onCasteChanged: (v) {
                              notifier.setCaste(v ?? '');
                            },
                          ),
                          const SizedBox(height: 24),

                          // ══ MY CLIENTS ONLY TOGGLE ══════════
                          _sectionLabel(AppLabels.scope(context)),
                          const SizedBox(height: 8),
                          _MyClientsTile(
                            value: filter.myClientsOnly,
                            onChanged: (_) => notifier.toggleMyClientsOnly(),
                          ),
                          const SizedBox(height: 24),

                          // ══ GENDER ═══════════════════════════
                          _sectionLabel(AppLabels.gender(context)),
                          const SizedBox(height: 10),
                          _SegmentGroup<GenderFilter>(
                            options: [
                              _SegOpt(GenderFilter.all, AppLabels.all(context), Icons.people),
                              _SegOpt(GenderFilter.male, AppLabels.male(context), Icons.male),
                              _SegOpt(
                                GenderFilter.female,
                                AppLabels.female(context),
                                Icons.female,
                              ),
                            ],
                            selected: filter.gender,
                            onSelect: notifier.setGender,
                          ),
                          const SizedBox(height: 24),

                          // ══ PAYMENT STATUS ════════════════════
                          _sectionLabel(AppLabels.paymentStatus(context)),
                          const SizedBox(height: 10),
                          _buildDropdown(
                            context: context,
                            title: AppLabels.payment(context),
                            value: _paymentLabel(context, filter.paymentStatus),
                            items: [
                              AppLabels.all(context),
                              AppLabels.paid(context),
                              AppLabels.pending(context),
                              AppLabels.notStarted(context),
                            ],
                            onChanged: (val) {
                              notifier.setPaymentStatus(
                                _paymentFromLabel(context, val),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // ══ PROFILE STATUS ════════════════════
                          _sectionLabel(AppLabels.profileStatus(context)),
                          const SizedBox(height: 10),
                          _SegmentGroup<ProfileStatusFilter>(
                            options: [
                              _SegOpt(
                                ProfileStatusFilter.all,
                                AppLabels.all(context),
                                Icons.remove_circle_outline,
                              ),
                              _SegOpt(
                                ProfileStatusFilter.active,
                                AppLabels.active(context),
                                Icons.check_circle_outline,
                              ),
                              _SegOpt(
                                ProfileStatusFilter.closed,
                                AppLabels.closed(context),
                                Icons.cancel_outlined,
                              ),
                            ],
                            selected: filter.profileStatus,
                            onSelect: notifier.setProfileStatus,
                          ),
                          const SizedBox(height: 24),

                          // ══ MATRIMONY PROFILE ═════════════════
                          _sectionLabel(AppLabels.matrimonyProfile(context)),
                          const SizedBox(height: 10),
                          _SegmentGroup<ProfileCreatedFilter>(
                            options: [
                              _SegOpt(
                                ProfileCreatedFilter.all,
                                AppLabels.all(context),
                                Icons.remove_circle_outline,
                              ),
                              _SegOpt(
                                ProfileCreatedFilter.created,
                                AppLabels.created(context),
                                Icons.person,
                              ),
                              _SegOpt(
                                ProfileCreatedFilter.notCreated,
                                AppLabels.notCreated(context),
                                Icons.person_off_outlined,
                              ),
                            ],
                            selected: filter.profileCreated,
                            onSelect: notifier.setProfileCreated,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // ─── APPLY BUTTON ───────────────────────────
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        filter.isDefault
                            ? AppLabels.apply(context)
                            : '${AppLabels.apply(context)}  •  ${filter.activeFilterCount} ${AppLabels.active(context)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── SECTION LABEL ─────────────────────────────────────
  static Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  // ─── DROPDOWN BUILDER ──────────────────────────────────
  static Widget _buildDropdown({
    required BuildContext context,
    required String title,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  // ─── PAYMENT LABEL HELPERS ─────────────────────────────
  static String _paymentLabel(BuildContext context, PaymentStatusFilter f) {
    switch (f) {
      case PaymentStatusFilter.paid:
        return AppLabels.paid(context);
      case PaymentStatusFilter.pending:
        return AppLabels.pending(context);
      case PaymentStatusFilter.notStarted:
        return AppLabels.notStarted(context);
      default:
        return AppLabels.all(context);
    }
  }

  static PaymentStatusFilter _paymentFromLabel(BuildContext context, String? label) {
    if (label == AppLabels.paid(context)) return PaymentStatusFilter.paid;
    if (label == AppLabels.pending(context)) return PaymentStatusFilter.pending;
    if (label == AppLabels.notStarted(context)) return PaymentStatusFilter.notStarted;
    return PaymentStatusFilter.all;
  }
}

// =====================================================
// LOCATION SECTION — State + City dropdowns
// =====================================================

class _LocationSection extends ConsumerWidget {
  final String selectedState;
  final String selectedCity;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCityChanged;

  const _LocationSection({
    required this.selectedState,
    required this.selectedCity,
    required this.onStateChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationJsonProvider);

    return locationAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(
        '${AppLabels.couldNotLoadLocations(context)}: $e',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
      data: (states) {
        final stateNames = states.map((s) => s.name).toList();

        final selectedStateObj = states.firstWhere(
          (s) => s.name == selectedState,
          orElse: () => StateCityModel(name: '', cities: []),
        );
        final cityNames = selectedStateObj.cities;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STATE ──────────────────────────────────
            DropdownButtonFormField<String>(
              value: selectedState.isEmpty ? null : selectedState,
              hint: Text(AppLabels.selectState(context)),
              isExpanded: true,
              items: [
                DropdownMenuItem(value: '', child: Text(AppLabels.allStates(context))),
                ...stateNames.map(
                  (s) => DropdownMenuItem(value: s, child: Text(s)),
                ),
              ],
              onChanged: onStateChanged,
              decoration: InputDecoration(
                labelText: AppLabels.state(context),
                prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── CITY / DISTRICT ────────────────────────
            DropdownButtonFormField<String>(
              value: selectedCity.isEmpty ? null : selectedCity,
              hint: Text(AppLabels.selectCityDistrict(context)),
              isExpanded: true,
              // disable city picker until a state is chosen
              onChanged: selectedState.isEmpty ? null : onCityChanged,
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(AppLabels.allCities(context)),
                ),
                ...cityNames.map(
                  (c) => DropdownMenuItem(value: c.name, child: Text(c.name)),
                ),
              ],
              decoration: InputDecoration(
                labelText: AppLabels.cityDistrict(context),
                prefixIcon: const Icon(
                  Icons.location_city_outlined,
                  size: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// CULTURAL SECTION — Religion + Caste dropdowns
// =====================================================

class _CulturalSection extends ConsumerWidget {
  final String selectedReligion;
  final String selectedCaste;
  final ValueChanged<String?> onReligionChanged;
  final ValueChanged<String?> onCasteChanged;

  const _CulturalSection({
    required this.selectedReligion,
    required this.selectedCaste,
    required this.onReligionChanged,
    required this.onCasteChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final religionsAsync = ref.watch(religionsProvider);

    return religionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(
        '${AppLabels.couldNotLoadReligions(context)}: $e',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
      data: (religions) {
        final religionNames = religions.map((r) => r.name).toList();

        final selectedReligionObj = religions.firstWhere(
          (r) => r.name == selectedReligion,
          orElse: () => ReligionCasteModel(id: '', name: '', castes: []),
        );
        final casteNames = selectedReligionObj.castes;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── RELIGION ───────────────────────────────
            DropdownButtonFormField<String>(
              value: selectedReligion.isEmpty ? null : selectedReligion,
              hint: Text(AppLabels.selectReligion(context)),
              isExpanded: true,
              items: [
                DropdownMenuItem(value: '', child: Text(AppLabels.allReligions(context))),
                ...religionNames.map(
                  (r) => DropdownMenuItem(value: r, child: Text(r)),
                ),
              ],
              onChanged: onReligionChanged,
              decoration: InputDecoration(
                labelText: AppLabels.religion(context),
                prefixIcon: const Icon(Icons.temple_hindu_outlined, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── CASTE ──────────────────────────────────
            DropdownButtonFormField<String>(
              value: selectedCaste.isEmpty ? null : selectedCaste,
              hint: Text(AppLabels.selectCaste(context)),
              isExpanded: true,
              // disable caste picker until a religion is chosen
              onChanged: selectedReligion.isEmpty ? null : onCasteChanged,
              items: [
                DropdownMenuItem(value: '', child: Text(AppLabels.allCastes(context))),
                ...casteNames.map(
                  (c) => DropdownMenuItem(value: c.name, child: Text(c.name)),
                ),
              ],
              decoration: InputDecoration(
                labelText: AppLabels.caste(context),
                prefixIcon: const Icon(Icons.people_alt_outlined, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// MY CLIENTS TILE
// =====================================================

class _MyClientsTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MyClientsTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: value
            ? theme.primaryColor.withValues(alpha: 0.07)
            : Colors.grey.shade100,
        border: Border.all(
          color: value
              ? theme.primaryColor.withValues(alpha: 0.35)
              : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 2,
        ),
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value
                ? theme.primaryColor.withValues(alpha: 0.12)
                : Colors.grey.shade200,
          ),
          child: Icon(
            value ? Icons.person : Icons.people_outline,
            size: 18,
            color: value ? theme.primaryColor : Colors.grey.shade500,
          ),
        ),
        title: Text(
          AppLabels.myClientsOnly(context),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: value ? theme.primaryColor : null,
          ),
        ),
        subtitle: Text(
          value ? AppLabels.assignedToYouOnly(context) : AppLabels.allAgents(context),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        value: value,
        activeThumbColor: theme.primaryColor,
        activeTrackColor: theme.primaryColor.withValues(alpha: 0.4),
        onChanged: onChanged,
      ),
    );
  }
}

// =====================================================
// GENERIC SEGMENT GROUP (row of outlined buttons)
// =====================================================

class _SegOpt<T> {
  final T value;
  final String label;
  final IconData icon;
  const _SegOpt(this.value, this.label, this.icon);
}

class _SegmentGroup<T> extends StatelessWidget {
  final List<_SegOpt<T>> options;
  final T selected;
  final void Function(T) onSelect;

  const _SegmentGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final sel = opt.value == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelect(opt.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: sel
                  ? theme.primaryColor
                  : theme.scaffoldBackgroundColor,
              border: Border.all(
                color: sel
                    ? theme.primaryColor
                    : Colors.grey.shade300,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  opt.icon,
                  size: 15,
                  color: sel ? theme.colorScheme.onPrimary : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sel
                        ? theme.colorScheme.onPrimary
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
