import 'package:arvika_marriage_bureau/app/custom/custom_widgets/shimmer.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/notifier/wishlist_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/user_drawer.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import 'my_profile_screen.dart';

@RoutePage()
class UserWishListScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserWishListScreen({super.key, required this.userId});

  @override
  ConsumerState<UserWishListScreen> createState() => _UserWishListScreenState();
}

class _UserWishListScreenState extends ConsumerState<UserWishListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WishlistStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load wishlists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(myWishlistNotifierProvider.notifier)
          .loadWishlists(widget.userId);
      ref
          .read(wishlistedMeNotifierProvider.notifier)
          .loadWishlists(widget.userId);
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
      drawer: UserDrawer(userAsync: profileAsync),
      backgroundColor: Colors.grey[100],
      body: paymentState.status == PayStatus.idle
          ? NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  title: const Text("Wishlist"),
                  centerTitle: true,
                  floating: true,
                  pinned: true,
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(100),
                    child: Column(
                      children: [
                        // Status Filter Chips
                        _buildStatusFilter(theme),
                        // Tab Bar
                        TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: theme.colorScheme.onPrimary,
                          unselectedLabelColor: theme.colorScheme.onPrimary
                              .withOpacity(0.7),
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              width: 3,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.favorite),
                              text: "My Wishlist",
                            ),
                            Tab(
                              icon: Icon(Icons.favorite_border),
                              text: "Wishlisted Me",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // My Wishlist Tab
                  _MyWishlistTab(
                    userId: widget.userId,
                    statusFilter: _selectedStatus,
                  ),
                  // Wishlisted Me Tab
                  _WishlistedMeTab(
                    userId: widget.userId,
                    statusFilter: _selectedStatus,
                  ),
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
          _buildFilterChip(null, "All", theme),
          ...WishlistStatus.values.map(
            (status) =>
                _buildFilterChip(status, _getStatusLabel(status), theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    WishlistStatus? status,
    String label,
    ThemeData theme,
  ) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : const Color.fromARGB(179, 31, 20, 20),
          fontSize: 12,
        ),
        backgroundColor: Colors.white24,
        selectedColor: _getStatusColor(status),
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
          // Update filters in notifiers
          ref
              .read(myWishlistNotifierProvider.notifier)
              .setStatusFilter(_selectedStatus);
          ref
              .read(wishlistedMeNotifierProvider.notifier)
              .setStatusFilter(_selectedStatus);
        },
      ),
    );
  }

  String _getStatusLabel(WishlistStatus status) {
    switch (status) {
      case WishlistStatus.pending:
        return "Pending";
      case WishlistStatus.contacted:
        return "Contacted";
      case WishlistStatus.interested:
        return "Interested";
      case WishlistStatus.notInterested:
        return "Not Interested";
      case WishlistStatus.closed:
        return "Closed";
    }
  }

  Color _getStatusColor(WishlistStatus? status) {
    if (status == null) return Colors.blue;
    switch (status) {
      case WishlistStatus.pending:
        return Colors.orange;
      case WishlistStatus.contacted:
        return Colors.blue;
      case WishlistStatus.interested:
        return Colors.green;
      case WishlistStatus.notInterested:
        return Colors.red;
      case WishlistStatus.closed:
        return Colors.grey;
    }
  }
}

/// ==========================================
/// My Wishlist Tab (User is sender)
/// ==========================================
class _MyWishlistTab extends ConsumerWidget {
  final String userId;
  final WishlistStatus? statusFilter;

  const _MyWishlistTab({required this.userId, this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(myWishlistNotifierProvider);

    if (wishlistState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wishlistState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: ${wishlistState.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(myWishlistNotifierProvider.notifier)
                    .loadWishlists(userId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final wishlists = wishlistState.filteredWishlists;

    if (wishlists.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: "Your wishlist is empty!",
        subtitle: "Start adding profiles to your wishlist to see them here.",
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(myWishlistNotifierProvider.notifier)
            .loadWishlists(userId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wishlists.length,
        itemBuilder: (context, index) {
          final wishlist = wishlists[index];
          return _WishlistItemCard(
            wishlist: wishlist,
            profileId: wishlist.receiverId, // Show receiver's profile
            currentUserId: userId,
            isMyWishlist: true,
            onStatusUpdate: (newStatus) async {
              await ref
                  .read(myWishlistNotifierProvider.notifier)
                  .updateStatus(
                    wishlistId: wishlist.id,
                    status: newStatus,
                    updatedBy: userId,
                  );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// Wishlisted Me Tab (User is receiver)
/// ==========================================
class _WishlistedMeTab extends ConsumerWidget {
  final String userId;
  final WishlistStatus? statusFilter;

  const _WishlistedMeTab({required this.userId, this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistedMeNotifierProvider);

    if (wishlistState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wishlistState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: ${wishlistState.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(wishlistedMeNotifierProvider.notifier)
                    .loadWishlists(userId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final wishlists = wishlistState.filteredWishlists;

    if (wishlists.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: "No one has wishlisted you yet!",
        subtitle:
            "When someone adds you to their wishlist, you'll see them here.",
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(wishlistedMeNotifierProvider.notifier)
            .loadWishlists(userId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wishlists.length,
        itemBuilder: (context, index) {
          final wishlist = wishlists[index];
          return _WishlistItemCard(
            wishlist: wishlist,
            profileId: wishlist.senderId, // Show sender's profile
            currentUserId: userId,
            isMyWishlist: false,
            onStatusUpdate: (newStatus) async {
              await ref
                  .read(wishlistedMeNotifierProvider.notifier)
                  .updateStatus(
                    wishlistId: wishlist.id,
                    status: newStatus,
                    updatedBy: userId,
                  );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// Wishlist Item Card Widget
/// ==========================================
class _WishlistItemCard extends ConsumerWidget {
  final WishlistEntity wishlist;
  final String profileId;
  final String currentUserId;
  final bool isMyWishlist;
  final Future<void> Function(String status) onStatusUpdate;

  const _WishlistItemCard({
    required this.wishlist,
    required this.profileId,
    required this.currentUserId,
    required this.isMyWishlist,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(matrimonyProfileProvider(profileId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: profileAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerLoading.rectangular(height: 80),
        ),
        error: (_, _) => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person_off),
          ),
          title: const Text('Could not load profile'),
          subtitle: Text('Profile ID: $profileId'),
        ),
        data: (profile) {
          final imageUrl = profile.images.primaryImageUrl;
          final hasImage = imageUrl.isNotEmpty;

          return InkWell(
            onTap: () {
              context.router.push(UserDetailRoute(uid: profile.user.uid));
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Profile Info Row
                  Row(
                    children: [
                      // Profile Image
                      Hero(
                        tag: 'wishlist-image-$profileId',
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: hasImage
                              ? NetworkImage(imageUrl)
                              : null,
                          child: !hasImage
                              ? Icon(Icons.person, color: Colors.grey.shade500)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Profile Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    profile.user.fullName.isNotEmpty
                                        ? profile.user.fullName
                                        : 'N/A',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatusBadge(wishlist.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.identity.age} Yrs • ${profile.employment.jobType.isNotEmpty ? profile.employment.jobType : 'N/A'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${profile.address.city}, ${profile.address.state}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
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
                  const SizedBox(height: 12),
                  // Action Row - Status Update
                  _buildActionRow(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Updated: ${_formatDateTime(wishlist.updatedAt)}',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () => _showStatusUpdateDialog(context),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Update Status'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WishlistStatus.values.map((status) {
            final isSelected = wishlist.status == status.name;
            return ListTile(
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status.name),
              ),
              title: Text(_getStatusLabel(status.name)),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              selected: isSelected,
              onTap: () async {
                Navigator.pop(context);
                try {
                  await onStatusUpdate(status.name);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Status updated to ${_getStatusLabel(status.name)}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update status: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'contacted':
        return 'Contacted';
      case 'interested':
        return 'Interested';
      case 'notinterested':
        return 'Not Interested';
      case 'closed':
        return 'Closed';
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

  String _formatDateTime(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
