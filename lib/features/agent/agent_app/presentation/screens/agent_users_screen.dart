import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/user_nofier.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/user_nofier.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';

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
      ref.read(usersPaymentsNotifierProvider.notifier).getUsersPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(agentUsersNotifierProvider);
    final paymentsAsync = ref.watch(usersPaymentsNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// 🔹 APP BAR
          const SliverAppBar(
            pinned: true,
            title: Text('Agent Clients'),
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
                return const SliverFillRemaining(
                  child: _EmptyView(),
                );
              }

              final payments = paymentsAsync.maybeWhen(
                data: (data) => data,
                orElse: () => const <Payment?>[],
              );

              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = users[index];

                      final Payment? userPayment = payments.firstWhere(
                        (p) => p != null && p.userId == user.uid,
                        orElse: () => null,
                      );

                      return UserCard(
                        user: user,
                        paymentStatus: userPayment?.status,

                        onViewUserProfile: () {
                          context.router.push(
                            ViewUserRoute(userId: user.uid),
                          );
                        },
                        onViewMatrimonyProfile: () {
                          context.router.push(
                            MetrimonyProfileRoute(userId: user.uid),
                          );
                        },
                        onViewPayment: () {
                          context.router.push(
                            ViewPaymentDetailRoute(userId: user.uid),
                          );
                        },
                      );
                    },
                    childCount: users.length,
                  ),
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
                    color: Colors.deepPurple.withOpacity(0.1),
                    image: (imageUrl != null && imageUrl.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (imageUrl == null || imageUrl.isEmpty)
                      ? Center(
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
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
                _InfoTile(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: user.phone.isNotEmpty ? user.phone : 'N/A',
                ),
                _StatusTile(
                  label: 'Profile',
                  value: user.isProfileCreated ? 'Created' : 'Pending',
                  isActive: user.isProfileCreated,
                ),
                _StatusTile(
                  label: 'Payment',
                  value: _paymentLabel(paymentStatus),
                  isActive: paymentStatus == 'SUCCESS',
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),

            /// ================= ACTION ROW =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.person_outline,
                  label: 'User',
                  onTap: onViewUserProfile,
                ),
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: 'Matrimony',
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

  String _paymentLabel(String? status) {
    if (status == null) return 'Not Started';

    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return 'Paid';
      case 'FAILED':
        return 'Failed';
      case 'PENDING':
        return 'Pending';
      default:
        return 'Not Started';
    }
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.22,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.05),

            border: Border.all(
              color: Colors.deepPurple.withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.deepPurple),
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
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
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
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.green : Colors.orange,
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
    return const Center(
      child: CircularProgressIndicator(color: Colors.deepPurple),
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
