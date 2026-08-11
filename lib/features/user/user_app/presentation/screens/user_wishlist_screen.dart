import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/custom/custom_widgets/shimmer.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/wishlist_notifier.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';

import '../../../../../../core/constants/app_labels.dart';
import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../domain/states/state_city.dart';
import 'my_profile_screen.dart';

@RoutePage()
class UserWishListScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserWishListScreen({super.key, required this.userId});

  @override
  ConsumerState<UserWishListScreen> createState() => _UserWishListScreenState();
}

class _UserWishListScreenState extends ConsumerState<UserWishListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WishlistStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load wishlists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myWishlistNotifierProvider.notifier).loadWishlists(widget.userId);
      ref.read(wishlistedMeNotifierProvider.notifier).loadWishlists(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final paymentState = ref.watch(paymentNotifierProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: paymentState.status == PayStatus.idle
          ? NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                ModernGradientAppBar(
                  title: AppLabels.wishlistTitle(context),
                  subtitle: AppLabels.manageInterests(context),
                  centerTitle: true,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildStatusFilter(theme)),
                        const SizedBox(height: 8),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: theme.primaryColor,
                          labelColor: theme.primaryColor,
                          unselectedLabelColor: theme.primaryColor,
                          tabs: [
                            Tab(text: AppLabels.myWishlist(context)),
                            Tab(text: AppLabels.wishlistedMe(context)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _MyWishlistTab(userId: widget.userId, statusFilter: _selectedStatus),
                  _WishlistedMeTab(userId: widget.userId, statusFilter: _selectedStatus),
                ],
              ),
            )
          : UserPaymentScreen(userId: widget.userId),
    );
  }

  Widget _buildStatusFilter(ThemeData theme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(null, AppLabels.all(context), theme),
          ...WishlistStatus.values.map((status) => _buildFilterChip(status, _getStatusLabel(status), theme)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WishlistStatus? status, String label, ThemeData theme) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.primaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        selectedColor: theme.primaryColor,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
          ref.read(myWishlistNotifierProvider.notifier).setStatusFilter(_selectedStatus);
          ref.read(wishlistedMeNotifierProvider.notifier).setStatusFilter(_selectedStatus);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }

  String _getStatusLabel(WishlistStatus status) {
    switch (status) {
      case WishlistStatus.pending:
        return AppLabels.pending(context);
      case WishlistStatus.contacted:
        return AppLabels.statusContacted(context);
      case WishlistStatus.interested:
        return AppLabels.statusInterested(context);
      case WishlistStatus.notInterested:
        return AppLabels.statusNotInterested(context);
      case WishlistStatus.closed:
        return AppLabels.closed(context);
    }
  }
}

class _MyWishlistTab extends ConsumerWidget {
  final String userId;
  final WishlistStatus? statusFilter;

  const _MyWishlistTab({required this.userId, this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(myWishlistStreamProvider(userId));

    return wishlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (wishlists) {
        final filteredWishlists = statusFilter == null ? wishlists : wishlists.where((w) => w.status == statusFilter!.name).toList();

        if (filteredWishlists.isEmpty) {
          return _buildEmptyState(
            context: context,
            icon: Icons.favorite_border,
            title: AppLabels.emptyWishlistTitle(context),
            subtitle: AppLabels.emptyWishlistSubtitle(context),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredWishlists.length,
          itemBuilder: (context, index) {
            final wishlist = filteredWishlists[index];
            return WishlistProfileCard(
              wishlist: wishlist,
              profileId: wishlist.receiverId,
              isMyWishlist: true,
              onStatusUpdate: (newStatus) async {
                await ref
                    .read(myWishlistNotifierProvider.notifier)
                    .updateStatus(wishlistId: wishlist.id, status: newStatus, updatedBy: userId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({required BuildContext context, required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistedMeTab extends ConsumerWidget {
  final String userId;
  final WishlistStatus? statusFilter;

  const _WishlistedMeTab({required this.userId, this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistedMeStreamProvider(userId));

    return wishlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (wishlists) {
        final filteredWishlists = statusFilter == null ? wishlists : wishlists.where((w) => w.status == statusFilter!.name).toList();

        if (filteredWishlists.isEmpty) {
          return _buildEmptyState(
            context: context,
            icon: Icons.people_outline,
            title: AppLabels.noOneWishlistedMeTitle(context),
            subtitle: AppLabels.noOneWishlistedMeSubtitle(context),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredWishlists.length,
          itemBuilder: (context, index) {
            final wishlist = filteredWishlists[index];
            return WishlistProfileCard(
              wishlist: wishlist,
              profileId: wishlist.senderId,
              isMyWishlist: false,
              onStatusUpdate: (newStatus) async {
                await ref
                    .read(wishlistedMeNotifierProvider.notifier)
                    .updateStatus(wishlistId: wishlist.id, status: newStatus, updatedBy: userId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({required BuildContext context, required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistProfileCard extends ConsumerWidget {
  final dynamic wishlist;
  final String profileId;
  final bool isMyWishlist;
  final Function(String) onStatusUpdate;

  const WishlistProfileCard({
    super.key,
    required this.wishlist,
    required this.profileId,
    required this.isMyWishlist,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locationAsync = ref.watch(locationJsonProvider);
    final profileAsync = ref.watch(matrimonyProfileProvider(profileId));
    final heroTag = 'wishlist-image-${wishlist.id}-$profileId-${isMyWishlist ? 'my' : 'me'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: profileAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: ShimmerLoading.rectangular(height: 100)),
        error: (_, _) => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person_off, color: Colors.grey),
          ),
          title: Text(AppLabels.couldNotLoadProfile(context)),
          subtitle: Text('${AppLabels.profileId(context)}: $profileId'),
        ),
        data: (profile) {
          final imageUrl = profile.images.primaryImageUrl;
          final hasImage = imageUrl.isNotEmpty;

          String resolvedState = profile.address.state.en;
          String resolvedCity = profile.address.city.en;

          if (locationAsync.hasValue) {
            final states = locationAsync.value!;
            final stateObj = states.where((s) => s.name == profile.address.state.en).firstOrNull;
            if (stateObj != null) {
              resolvedState = stateObj.name;
              final cityObj = stateObj.cities
                  .where((c) => c.id == profile.address.city.en || c.name == profile.address.city.en)
                  .firstOrNull;
              if (cityObj != null) {
                resolvedCity = cityObj.name;
              }
            }
          }

          return InkWell(
            onTap: () {
              context.router.push(UserDetailRoute(uid: profile.user.uid));
            },
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Hero(
                        tag: heroTag,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: theme.primaryColor.withValues(alpha: 0.05),
                            backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                            child: !hasImage ? Icon(Icons.person, color: theme.primaryColor, size: 30) : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Profile Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: BilingualParser(
                                    value: profile.user.fullName.en.isNotEmpty ? profile.user.fullName : BilingualValue.empty(),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatusBadge(context, wishlist.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${profile.identity.age} ${AppLabels.ageYrs(context)} • ${profile.employment.jobType.isNotEmpty ? profile.employment.jobType : AppLabels.notAvailableShort(context)}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: theme.primaryColor.withValues(alpha: 0.6)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '$resolvedCity, $resolvedState',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey[100]),
                // Action Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(_formatDateTime(context, wishlist.updatedAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showStatusUpdateDialog(context),
                        icon: Icon(Icons.edit_note, size: 18, color: theme.primaryColor),
                        label: Text(
                          AppLabels.updateStatus(context),
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        _getStatusLabel(context, status),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(AppLabels.updateStatus(context), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ...WishlistStatus.values.map((status) {
              final isSelected = wishlist.status == status.name;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _getStatusColor(status.name).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(_getStatusIcon(status), color: _getStatusColor(status.name), size: 20),
                ),
                title: Text(
                  _getStatusLabel(context, status.name),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.black87,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await onStatusUpdate(status.name);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLabels.statusUpdatedTo(context, _getStatusLabel(context, status.name))),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLabels.failedToUpdateStatus(context, e.toString())), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(WishlistStatus status) {
    switch (status) {
      case WishlistStatus.pending:
        return Icons.hourglass_empty;
      case WishlistStatus.contacted:
        return Icons.phone;
      case WishlistStatus.interested:
        return Icons.thumb_up;
      case WishlistStatus.notInterested:
        return Icons.thumb_down;
      case WishlistStatus.closed:
        return Icons.check_circle;
    }
  }

  String _getStatusLabel(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppLabels.pending(context);
      case 'contacted':
        return AppLabels.statusContacted(context);
      case 'interested':
        return AppLabels.statusInterested(context);
      case 'notinterested':
        return AppLabels.statusNotInterested(context);
      case 'closed':
        return AppLabels.closed(context);
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'contacted':
        return Colors.blue;
      case 'interested':
        return Colors.green;
      case 'notinterested':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return AppLabels.notAvailableShort(context);
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
