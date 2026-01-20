import 'package:flutter_riverpod/legacy.dart';

import '../../../../../app/custom/custom_widgets/drawer.dart';
import 'agen_profile.screen.dart';

import '../../../../../app/router/app_router.dart';
import '../notifier/user_nofier.dart';
import '../../../../auth/domain/states/user_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../user/user_razorpay/domain/states/payment.dart';

enum GenderFilter { male, female }

final genderFilterProvider = StateProvider<GenderFilter>(
  (ref) => GenderFilter.male,
);

class GenderFilterRow extends ConsumerWidget {
  const GenderFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(genderFilterProvider);
    final theme = Theme.of(context);

    Widget buildButton(String label, GenderFilter value,  ) {
      final isSelected = selected == value;

      return Expanded(
        child: OutlinedButton.icon(
      
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: isSelected
                ? theme.colorScheme.onPrimary
                : theme.primaryColor,
            backgroundColor: isSelected
                ? theme.primaryColor
                : Colors.transparent,
            side: BorderSide(color: theme.primaryColor),
          ),
          onPressed: () {
            ref.read(genderFilterProvider.notifier).state = value;
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          buildButton('Male', GenderFilter.male, ),
          const SizedBox(width: 12),
          buildButton('Female', GenderFilter.female,  ),
        ],
      ),
    );
  }
}

@RoutePage()
class AgentUserScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentUserScreen({super.key, required this.agentId});

  @override
  ConsumerState<AgentUserScreen> createState() => _AgentUserScreenState();
}

class _AgentUserScreenState extends ConsumerState<AgentUserScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(agentUsersNotifierProvider.notifier)
          .getUsersForAgent(widget.agentId);

      ref
          .read(usersPaymentsNotifierProvider.notifier)
          .getUsersPayment(agentId: widget.agentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(agentUsersNotifierProvider);
    final paymentsAsync = ref.watch(usersPaymentsNotifierProvider);
    final genderFilter = ref.watch(genderFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(agentAsync: ref.watch(agentProvider(widget.agentId))),
      body: CustomScrollView(
        slivers: [
          /// 🔹 APP BAR
          SliverAppBar(
            title: const Text('My Clients'),
            floating: true,
            pinned: true,
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
          ),

          /// 🔹 GENDER FILTER ROW
          SliverAppBar(
            toolbarHeight: 30,
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,

            flexibleSpace: const GenderFilterRow(),
          ),

          /// 🔹 USER LIST
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
                  onRetry: () {
                    ref
                        .read(agentUsersNotifierProvider.notifier)
                        .getUsersForAgent(widget.agentId);
                  },
                ),
              );
            },

            data: (users) {
              if (users.isEmpty) {
                return const SliverFillRemaining(child: _EmptyView());
              }

              /// 🔹 FILTER USERS BY GENDER
              final filteredUsers = users.where((user) {
                final gender = user.gender?.toLowerCase() ?? '';
                return genderFilter == GenderFilter.male
                    ? gender == 'male'
                    : gender == 'female';
              }).toList();

              if (filteredUsers.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No users found')),
                );
              }

              /// 🔹 PAYMENTS
              final payments = paymentsAsync.maybeWhen(
                data: (data) => data,
                orElse: () => const <Payment?>[],
              );

              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = filteredUsers[index];

                    final userPayments = payments
                        .where((p) => p != null && p.userId == user.uid)
                        .toList();

                    String statusToDisplay = 'Not Started';

                    if (userPayments.any(
                      (p) => [
                        'SUCCESS',
                        'PAID',
                        'CAPTURED',
                      ].contains(p?.status.toUpperCase()),
                    )) {
                      statusToDisplay = 'PAID';
                    } else if (userPayments.any(
                      (p) => p?.status.toUpperCase() == 'PENDING',
                    )) {
                      statusToDisplay = 'PENDING';
                    }

                    return UserCard(
                      user: user,
                      paymentStatus: statusToDisplay,
                      onViewUserProfile: () {
                        context.router.push(ViewUserRoute(userId: user.uid));
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
                  }, childCount: filteredUsers.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
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
              label: isProfileCreated ? 'Active' : 'Pending',
              color: isProfileCreated ? Colors.green : Colors.orange,
            ),
          ),

          // Info Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Phone
                Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  user.phone.isNotEmpty ? user.phone : 'N/A',
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                // Payment Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPaymentColor(paymentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: _getPaymentColor(paymentStatus),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        paymentStatus ?? 'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getPaymentColor(paymentStatus),
                        ),
                      ),
                    ],
                  ),
                ),
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

  Color _getPaymentColor(String? status) {
    switch (status?.toUpperCase()) {
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

/// =======================================================
/// EMPTY VIEW
/// =======================================================
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

/// =======================================================
/// LOADING VIEW
/// =======================================================
class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// =======================================================
/// ERROR VIEW
/// =======================================================
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
