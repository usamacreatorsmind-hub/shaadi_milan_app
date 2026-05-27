import 'package:flutter_riverpod/legacy.dart';

import '../../../../../app/custom/custom_widgets/drawer.dart';
import '../../../../../core/filters/client_filter_right_sheet.dart';
import 'agen_profile.screen.dart';

import '../../../../../app/router/app_router.dart';
import '../notifier/user_nofier.dart';
import '../../../../auth/domain/states/user_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../user/user_razorpay/domain/states/payment.dart';

// =====================================================
// FILTER ENUMS
// =====================================================

enum GenderFilter { all, male, female }

enum PaymentStatusFilter { all, paid, pending, notStarted }

enum ProfileStatusFilter { all, active, closed }

enum ProfileCreatedFilter { all, created, notCreated }

// =====================================================
// FILTER STATE
// =====================================================

class ClientFilterState {
  final GenderFilter gender;
  final PaymentStatusFilter paymentStatus;
  final ProfileStatusFilter profileStatus;
  final ProfileCreatedFilter profileCreated;
  final String searchQuery;
  final bool myClientsOnly; // ← NEW: show only this agent's clients

  const ClientFilterState({
    this.gender = GenderFilter.all,
    this.paymentStatus = PaymentStatusFilter.all,
    this.profileStatus = ProfileStatusFilter.all,
    this.profileCreated = ProfileCreatedFilter.all,
    this.searchQuery = '',
    this.myClientsOnly = false,
  });

  ClientFilterState copyWith({
    GenderFilter? gender,
    PaymentStatusFilter? paymentStatus,
    ProfileStatusFilter? profileStatus,
    ProfileCreatedFilter? profileCreated,
    String? searchQuery,
    bool? myClientsOnly,
  }) {
    return ClientFilterState(
      gender: gender ?? this.gender,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      profileStatus: profileStatus ?? this.profileStatus,
      profileCreated: profileCreated ?? this.profileCreated,
      searchQuery: searchQuery ?? this.searchQuery,
      myClientsOnly: myClientsOnly ?? this.myClientsOnly,
    );
  }

  bool get isDefault =>
      gender == GenderFilter.all &&
      paymentStatus == PaymentStatusFilter.all &&
      profileStatus == ProfileStatusFilter.all &&
      profileCreated == ProfileCreatedFilter.all &&
      searchQuery.isEmpty &&
      !myClientsOnly;

  int get activeFilterCount {
    int count = 0;
    if (gender != GenderFilter.all) count++;
    if (paymentStatus != PaymentStatusFilter.all) count++;
    if (profileStatus != ProfileStatusFilter.all) count++;
    if (profileCreated != ProfileCreatedFilter.all) count++;
    if (searchQuery.isNotEmpty) count++;
    if (myClientsOnly) count++;
    return count;
  }
}

// =====================================================
// FILTER PROVIDER
// =====================================================

final clientFilterProvider =
    StateNotifierProvider<ClientFilterNotifier, ClientFilterState>((ref) {
      return ClientFilterNotifier();
    });

class ClientFilterNotifier extends StateNotifier<ClientFilterState> {
  ClientFilterNotifier() : super(const ClientFilterState());

  void setGender(GenderFilter v) => state = state.copyWith(gender: v);
  void setPaymentStatus(PaymentStatusFilter v) =>
      state = state.copyWith(paymentStatus: v);
  void setProfileStatus(ProfileStatusFilter v) =>
      state = state.copyWith(profileStatus: v);
  void setProfileCreated(ProfileCreatedFilter v) =>
      state = state.copyWith(profileCreated: v);
  void setSearch(String v) => state = state.copyWith(searchQuery: v);
  void toggleMyClientsOnly() =>
      state = state.copyWith(myClientsOnly: !state.myClientsOnly);
  void reset() => state = const ClientFilterState();
}

// =====================================================
// MAIN SCREEN
// =====================================================

@RoutePage()
class AgentUserScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentUserScreen({super.key, required this.agentId});

  @override
  ConsumerState<AgentUserScreen> createState() => _AgentUserScreenState();
}

class _AgentUserScreenState extends ConsumerState<AgentUserScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentUsersNotifierProvider.notifier).getUsersForAgent();
      ref
          .read(usersPaymentsNotifierProvider.notifier)
          .getUsersPayment(agentId: widget.agentId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(agentUsersNotifierProvider);
    final paymentsAsync = ref.watch(usersPaymentsNotifierProvider);
    final filter = ref.watch(clientFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(agentAsync: ref.watch(agentProvider(widget.agentId))),
      body: CustomScrollView(
        slivers: [
          // ─── APP BAR ───────────────────────────────────────
          SliverAppBar(
            title: const Text('My Clients'),
            floating: true,
            pinned: true,
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            actions: [
              // ── MY CLIENTS ONLY TOGGLE ──────────────────────
              GestureDetector(
                onTap: () => ref
                    .read(clientFilterProvider.notifier)
                    .toggleMyClientsOnly(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: filter.myClientsOnly
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.myClientsOnly
                            ? Icons.person
                            : Icons.person_outline,
                        size: 15,
                        color: filter.myClientsOnly
                            ? theme.primaryColor
                            : Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'My Clients',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: filter.myClientsOnly
                              ? theme.primaryColor
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Mini toggle indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: filter.myClientsOnly
                              ? theme.primaryColor
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: filter.myClientsOnly
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: filter.myClientsOnly
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── FILTER ICON WITH BADGE ──────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter Clients',
                    onPressed: () => showClientFilterSheet(context),
                  ),
                  if (filter.activeFilterCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${filter.activeFilterCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (!filter.isDefault)
                TextButton(
                  onPressed: () {
                    ref.read(clientFilterProvider.notifier).reset();
                    _searchController.clear();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),

          // ─── SEARCH BAR ────────────────────────────────────
          SliverAppBar(
            toolbarHeight: 58,
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    ref.read(clientFilterProvider.notifier).setSearch(v),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: filter.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(clientFilterProvider.notifier)
                                .setSearch('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
              ),
            ),
          ),

          // ─── QUICK GENDER CHIPS ────────────────────────────
          SliverAppBar(
            toolbarHeight: 44,
            automaticallyImplyLeading: false,
            pinned: false,
            floating: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: _QuickGenderChips(),
          ),

          // ─── ACTIVE FILTER CHIPS ──────────────────────────
          if (!filter.isDefault)
            SliverToBoxAdapter(
              child: _ActiveFilterChips(
                filter: filter,
                onRemoveSearch: () {
                  _searchController.clear();
                  ref.read(clientFilterProvider.notifier).setSearch('');
                },
              ),
            ),

          // ─── USER LIST ────────────────────────────────────
          usersAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),

            error: (error, stackTrace) {
              debugPrint(stackTrace.toString());
              debugPrint(error.toString());
              return SliverFillRemaining(
                child: _ErrorView(
                  error: error.toString(),
                  onRetry: () => ref
                      .read(agentUsersNotifierProvider.notifier)
                      .getUsersForAgent(),
                ),
              );
            },

            data: (users) {
              if (users.isEmpty) {
                return const SliverFillRemaining(child: _EmptyView());
              }

              // Fetch payments once
              final payments = paymentsAsync.maybeWhen(
                data: (data) => data,
                orElse: () => const <Payment?>[],
              );

              // Resolve payment status per user
              String resolvePaymentStatus(String uid) {
                final userPayments =
                    payments.where((p) => p != null && p.userId == uid);
                if (userPayments.any(
                  (p) => ['SUCCESS', 'PAID', 'CAPTURED']
                      .contains(p?.status.toUpperCase()),
                )) {
                  return 'PAID';
                } else if (userPayments.any(
                  (p) => p?.status.toUpperCase() == 'PENDING',
                )) {
                  return 'PENDING';
                }
                return 'Not Started';
              }

              // ── APPLY FILTERS ──────────────────────────────
              final filteredUsers = users.where((user) {
                // My Clients Only toggle
                if (filter.myClientsOnly &&
                    user.agentId != widget.agentId) {
                  return false;
                }

                // Gender
                if (filter.gender != GenderFilter.all) {
                  final g = user.gender.toLowerCase();
                  if (filter.gender == GenderFilter.male && g != 'male') {
                    return false;
                  }
                  if (filter.gender == GenderFilter.female && g != 'female') {
                    return false;
                  }
                }

                // Payment status
                if (filter.paymentStatus != PaymentStatusFilter.all) {
                  final ps = resolvePaymentStatus(user.uid);
                  switch (filter.paymentStatus) {
                    case PaymentStatusFilter.paid:
                      if (ps != 'PAID') return false;
                      break;
                    case PaymentStatusFilter.pending:
                      if (ps != 'PENDING') return false;
                      break;
                    case PaymentStatusFilter.notStarted:
                      if (ps != 'Not Started') return false;
                      break;
                    default:
                      break;
                  }
                }

                // Profile status
                if (filter.profileStatus != ProfileStatusFilter.all) {
                  final ps = user.profileStatus.toLowerCase();
                  if (filter.profileStatus == ProfileStatusFilter.active &&
                      ps != 'active') {
                    return false;
                  }
                  if (filter.profileStatus == ProfileStatusFilter.closed &&
                      ps != 'closed') {
                    return false;
                  }
                }

                // Profile created
                if (filter.profileCreated != ProfileCreatedFilter.all) {
                  if (filter.profileCreated == ProfileCreatedFilter.created &&
                      !user.isProfileCreated) {
                    return false;
                  }
                  if (filter.profileCreated == ProfileCreatedFilter.notCreated &&
                      user.isProfileCreated) {
                    return false;
                  }
                }

                // Search
                if (filter.searchQuery.isNotEmpty) {
                  final q = filter.searchQuery.toLowerCase();
                  if (!user.fullName.toLowerCase().contains(q) &&
                      !user.phone.toLowerCase().contains(q) &&
                      !user.email.toLowerCase().contains(q)) {
                    return false;
                  }
                }

                return true;
              }).toList();

              if (filteredUsers.isEmpty) {
                return SliverFillRemaining(
                  child: _NoResultsView(
                    onClearFilters: () {
                      ref.read(clientFilterProvider.notifier).reset();
                      _searchController.clear();
                    },
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = filteredUsers[index];
                      final statusToDisplay = resolvePaymentStatus(user.uid);

                      return UserCard(
                        user: user,
                        paymentStatus: statusToDisplay,
                        onViewUserProfile: () {
                          context.router
                              .push(ViewUserRoute(userId: user.uid));
                        },
                        onViewMatrimonyProfile: () {
                          if (user.isProfileCreated) {
                            context.router.push(
                              MetrimonyProfileRoute(userId: user.uid),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Matrimony profile not created yet',
                                ),
                              ),
                            );
                          }
                        },
                        onViewPayment: () {
                          context.router.push(
                            ViewPaymentDetailRoute(
                              userId: user.uid,
                              agentId: user.agentId,
                            ),
                          );
                        },
                      );
                    },
                    childCount: filteredUsers.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── FILTER BOTTOM SHEET ──────────────────────────────────
}

// =====================================================
// QUICK GENDER CHIPS (always visible)
// =====================================================

class _QuickGenderChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(clientFilterProvider);
    final theme = Theme.of(context);

    Widget chip(String label, GenderFilter value, IconData icon) {
      final sel = filter.gender == value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          avatar: Icon(
            icon,
            size: 16,
            color: sel ? theme.colorScheme.onPrimary : theme.primaryColor,
          ),
          label: Text(label),
          selected: sel,
          onSelected: (_) =>
              ref.read(clientFilterProvider.notifier).setGender(value),
          selectedColor: theme.primaryColor,
          checkmarkColor: theme.colorScheme.onPrimary,
          labelStyle: TextStyle(
            color: sel ? theme.colorScheme.onPrimary : null,
            fontSize: 13,
          ),
          side: BorderSide(
            color: sel ? theme.primaryColor : Colors.grey.shade300,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          chip('All', GenderFilter.all, Icons.people),
          chip('Male', GenderFilter.male, Icons.male),
          chip('Female', GenderFilter.female, Icons.female),
        ],
      ),
    );
  }
}

// =====================================================
// ACTIVE FILTER CHIPS (dismissible summary row)
// =====================================================

class _ActiveFilterChips extends ConsumerWidget {
  final ClientFilterState filter;
  final VoidCallback onRemoveSearch;

  const _ActiveFilterChips({
    required this.filter,
    required this.onRemoveSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(clientFilterProvider.notifier);
    final chips = <Widget>[];

    if (filter.myClientsOnly) {
      chips.add(_chip(
        'My Clients Only',
        Icons.person,
        Colors.indigo,
        () => notifier.toggleMyClientsOnly(),
      ));
    }
    if (filter.paymentStatus != PaymentStatusFilter.all) {
      chips.add(_chip(
        _paymentLabel(filter.paymentStatus),
        Icons.payments_outlined,
        Colors.green,
        () => notifier.setPaymentStatus(PaymentStatusFilter.all),
      ));
    }
    if (filter.profileStatus != ProfileStatusFilter.all) {
      chips.add(_chip(
        _profileStatusLabel(filter.profileStatus),
        Icons.person_pin,
        Colors.blue,
        () => notifier.setProfileStatus(ProfileStatusFilter.all),
      ));
    }
    if (filter.profileCreated != ProfileCreatedFilter.all) {
      chips.add(_chip(
        _profileCreatedLabel(filter.profileCreated),
        Icons.create_outlined,
        Colors.orange,
        () => notifier.setProfileCreated(ProfileCreatedFilter.all),
      ));
    }
    if (filter.searchQuery.isNotEmpty) {
      chips.add(_chip(
        '"${filter.searchQuery}"',
        Icons.search,
        Colors.purple,
        onRemoveSearch,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }

  Widget _chip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onRemove,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        avatar: Icon(icon, size: 14, color: color),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        backgroundColor: color.withValues(alpha: 0.08),
      ),
    );
  }

  String _paymentLabel(PaymentStatusFilter f) {
    switch (f) {
      case PaymentStatusFilter.paid:
        return 'Paid';
      case PaymentStatusFilter.pending:
        return 'Payment Pending';
      case PaymentStatusFilter.notStarted:
        return 'Not Started';
      default:
        return '';
    }
  }

  String _profileStatusLabel(ProfileStatusFilter f) {
    switch (f) {
      case ProfileStatusFilter.active:
        return 'Active';
      case ProfileStatusFilter.closed:
        return 'Closed';
      default:
        return '';
    }
  }

  String _profileCreatedLabel(ProfileCreatedFilter f) {
    switch (f) {
      case ProfileCreatedFilter.created:
        return 'Profile Created';
      case ProfileCreatedFilter.notCreated:
        return 'Profile Pending';
      default:
        return '';
    }
  }
}

// =====================================================
// FILTER BOTTOM SHEET
// =====================================================


// =====================================================
// USER CARD
// =====================================================

class UserCard extends StatelessWidget {
  final UserEntity user;
  final String? paymentStatus;

  final VoidCallback onViewUserProfile;
  final VoidCallback onViewMatrimonyProfile;
  final VoidCallback onViewPayment;

  const UserCard({
    super.key,
    required this.user,
    this.paymentStatus,
    required this.onViewUserProfile,
    required this.onViewMatrimonyProfile,
    required this.onViewPayment,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImageUrl;
    final theme = Theme.of(context);
    final isProfileCreated = user.isProfileCreated;
    final profileStatus = user.profileStatus;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            leading: Hero(
              tag: 'user-avatar-${user.uid}',
              child: CircleAvatar(
                radius: 30,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: imageUrl.isEmpty
                    ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            title: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              user.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: _StatusBadge(
              label: isProfileCreated ? 'Created' : 'Pending',
              color: isProfileCreated ? Colors.green : Colors.orange,
            ),
          ),

          // Info Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  user.phone.isNotEmpty ? user.phone : 'N/A',
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                _PaymentBadge(status: paymentStatus),
                const SizedBox(width: 8),
                _ProfileStatusBadge(status: profileStatus),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // Actions
          Row(
            children: [
              Expanded(
                child: _TextActionButton(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  onTap: onViewUserProfile,
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              Expanded(
                child: _TextActionButton(
                  icon: Icons.favorite_border,
                  label: 'Matrimony',
                  onTap: onViewMatrimonyProfile,
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              Expanded(
                child: _TextActionButton(
                  icon: Icons.receipt_long_outlined,
                  label: 'Payment',
                  onTap: onViewPayment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String? status;
  const _PaymentBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status ?? 'N/A',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _color(String? s) {
    switch (s?.toUpperCase()) {
      case 'PAID':
      case 'SUCCESS':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ProfileStatusBadge extends StatelessWidget {
  final String? status;
  const _ProfileStatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_pin, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            (status ?? 'N/A').toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _color(String? s) {
    switch (s?.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'CLOSED':
        return const Color.fromARGB(255, 211, 8, 19);
      default:
        return Colors.grey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _TextActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TextActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// EMPTY / NO RESULTS / ERROR VIEWS
// =====================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Clients Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final VoidCallback onClearFilters;
  const _NoResultsView({required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No Matching Clients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters to find what you\'re looking for.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Clients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
