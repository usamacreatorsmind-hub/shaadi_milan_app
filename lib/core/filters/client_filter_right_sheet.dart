import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/agent/agent_app/presentation/screens/agent_users_screen.dart';

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
    barrierLabel: 'Client Filter',
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
                          const Text(
                            'Filter Clients',
                            style: TextStyle(
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
                                'Reset',
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
                        '${filter.activeFilterCount} filter${filter.activeFilterCount > 1 ? 's' : ''} active',
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
                          // ══ MY CLIENTS ONLY TOGGLE ══════════
                          _sectionLabel('Scope'),
                          const SizedBox(height: 8),
                          _MyClientsTile(
                            value: filter.myClientsOnly,
                            onChanged: (_) => notifier.toggleMyClientsOnly(),
                          ),
                          const SizedBox(height: 24),

                          // ══ GENDER ═══════════════════════════
                          _sectionLabel('Gender'),
                          const SizedBox(height: 10),
                          _SegmentGroup<GenderFilter>(
                            options: const [
                              _SegOpt(GenderFilter.all, 'All', Icons.people),
                              _SegOpt(GenderFilter.male, 'Male', Icons.male),
                              _SegOpt(
                                GenderFilter.female,
                                'Female',
                                Icons.female,
                              ),
                            ],
                            selected: filter.gender,
                            onSelect: notifier.setGender,
                          ),
                          const SizedBox(height: 24),

                          // ══ PAYMENT STATUS ════════════════════
                          _sectionLabel('Payment Status'),
                          const SizedBox(height: 10),
                          _buildDropdown(
                            context: context,
                            title: 'Payment',
                            value: _paymentLabel(filter.paymentStatus),
                            items: const [
                              'All',
                              'Paid',
                              'Pending',
                              'Not Started',
                            ],
                            onChanged: (val) {
                              notifier.setPaymentStatus(
                                _paymentFromLabel(val),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // ══ PROFILE STATUS ════════════════════
                          _sectionLabel('Profile Status'),
                          const SizedBox(height: 10),
                          _SegmentGroup<ProfileStatusFilter>(
                            options: const [
                              _SegOpt(
                                ProfileStatusFilter.all,
                                'All',
                                Icons.remove_circle_outline,
                              ),
                              _SegOpt(
                                ProfileStatusFilter.active,
                                'Active',
                                Icons.check_circle_outline,
                              ),
                              _SegOpt(
                                ProfileStatusFilter.closed,
                                'Closed',
                                Icons.cancel_outlined,
                              ),
                            ],
                            selected: filter.profileStatus,
                            onSelect: notifier.setProfileStatus,
                          ),
                          const SizedBox(height: 24),

                          // ══ MATRIMONY PROFILE ═════════════════
                          _sectionLabel('Matrimony Profile'),
                          const SizedBox(height: 10),
                          _SegmentGroup<ProfileCreatedFilter>(
                            options: const [
                              _SegOpt(
                                ProfileCreatedFilter.all,
                                'All',
                                Icons.remove_circle_outline,
                              ),
                              _SegOpt(
                                ProfileCreatedFilter.created,
                                'Created',
                                Icons.person,
                              ),
                              _SegOpt(
                                ProfileCreatedFilter.notCreated,
                                'Pending',
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
                            ? 'Apply'
                            : 'Apply  •  ${filter.activeFilterCount} active',
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
      initialValue: value,
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
  static String _paymentLabel(PaymentStatusFilter f) {
    switch (f) {
      case PaymentStatusFilter.paid:
        return 'Paid';
      case PaymentStatusFilter.pending:
        return 'Pending';
      case PaymentStatusFilter.notStarted:
        return 'Not Started';
      default:
        return 'All';
    }
  }

  static PaymentStatusFilter _paymentFromLabel(String? label) {
    switch (label) {
      case 'Paid':
        return PaymentStatusFilter.paid;
      case 'Pending':
        return PaymentStatusFilter.pending;
      case 'Not Started':
        return PaymentStatusFilter.notStarted;
      default:
        return PaymentStatusFilter.all;
    }
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
          'My Clients Only',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: value ? theme.primaryColor : null,
          ),
        ),
        subtitle: Text(
          value ? 'Assigned to you only' : 'All agents',
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
