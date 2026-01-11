import 'package:sizer/sizer.dart';

import '../../../../../app/router/app_router.dart';
import '../notifier/user_nofier.dart';
import '../../../../auth/domain/states/user_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../user/user_razorpay/domain/states/payment.dart';

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

    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// 🔹 APP BAR
          SliverAppBar(
            title: const Text('My Clients'),
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),

          /// 🔹 BODY
          usersAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),

            error: (error, _) => SliverFillRemaining(
              child: _ErrorView(
                error: error.toString(),
                onRetry: () {
                  ref
                      .read(agentUsersNotifierProvider.notifier)
                      .getUsersForAgent(widget.agentId);
                },
              ),
            ),

            data: (users) {
              if (users.isEmpty) {
                return const SliverFillRemaining(child: _EmptyView());
              }

              // Get payments from async state
              final payments = paymentsAsync.maybeWhen(
                data: (data) => data,
                orElse: () => const <Payment?>[],
              );

              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = users[index];
                    // print payments

                    // Find all payments for this user
                    final userPayments = payments
                        .where((p) => p != null && p.userId == user.uid)
                        .toList();

                    // debugPrint(
                    //   'User ${user.fullName}: Payments: ${userPayments.map((p) => p?.status).toList()}',
                    // );

                    // Determine the payment status to display
                    String? statusToDisplay;

                    if (userPayments.isEmpty) {
                      // No payments found for this user
                      statusToDisplay = 'Not Started';
                    } else {
                      // Check for successful payments
                      final hasSuccess = userPayments.any(
                        (p) =>
                            p != null &&
                            [
                              'SUCCESS',
                              'PAID',
                              'CAPTURED',
                            ].contains(p.status.toUpperCase()),
                      );

                      if (hasSuccess) {
                        statusToDisplay = 'PAID';
                      } else {
                        // Check for pending payments
                        final hasPending = userPayments.any(
                          (p) =>
                              p != null && p.status.toUpperCase() == 'PENDING',
                        );

                        if (hasPending) {
                          statusToDisplay = 'PENDING';
                        } else {
                          // Use the most recent payment status
                          statusToDisplay =
                              userPayments.isNotEmpty &&
                                  userPayments.first != null
                              ? userPayments.first!.status
                              : 'Not Started';
                        }
                      }
                    }

                    return UserCard(
                      user: user,
                      paymentStatus: statusToDisplay,

                      onViewUserProfile: () {
                        context.router.push(
                          ViewUserRoute(
                            userId: user.uid,
                            agentId: widget.agentId,
                          ),
                        );
                      },
                      onViewMatrimonyProfile: () {
                        context.router.push(
                          MetrimonyProfileRoute(userId: user.uid),
                        );
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
                  }, childCount: users.length),
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= HEADER =================
            Row(
              children: [
                /// Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? Center(
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                /// Name & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            /// ================= STATUS ROW =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30.w,
                  child: _InfoTile(
                    label: 'Phone',
                    value: user.phone.isNotEmpty ? user.phone : 'N/A',
                  ),
                ),
                Container(
                  width: 25.w,
                  child: _StatusTile(
                    label: 'Profile',
                    value: user.isProfileCreated ? 'Created' : 'Pending',
                    isActive: user.isProfileCreated,
                  ),
                ),
                Container(
                  width: 26.w,
                  child: _StatusTile(
                    label: 'Payment',
                    value: paymentStatus ?? 'Not Started',
                    isActive: paymentStatus?.toUpperCase() == 'PAID',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            /// ================= ACTION ROW =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.person_outline,
                  label: 'View Profile',
                  onTap: onViewUserProfile,
                ),
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: 'View Matrimony',
                  onTap: onViewMatrimonyProfile,
                ),
                _ActionButton(
                  icon: Icons.payments_outlined,
                  label: 'Payment',
                  onTap: onViewPayment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Container(
          width: 26.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),

            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// INFO TILE
/// =======================================================
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),

                  color: Colors.transparent,
                ),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// =======================================================
/// STATUS TILE
/// =======================================================
class _StatusTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;

  const _StatusTile({
    required this.label,
    required this.value,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on payment status
    Color statusColor = Colors.grey;
    if (value.toUpperCase() == 'PAID') {
      statusColor = Colors.green;
    } else if (value.toUpperCase() == 'PENDING') {
      statusColor = Colors.orange;
    } else if (value.toUpperCase() == 'FAILED') {
      statusColor = Colors.red;
    } else if (value.toUpperCase() == 'NOT STARTED') {
      statusColor = Colors.grey;
    }

    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Container(
          width: 20.w,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ),
      ],
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
        children: const [
          Icon(Icons.people_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Clients Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
