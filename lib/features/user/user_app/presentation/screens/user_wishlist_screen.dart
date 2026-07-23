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
import '../../../../../app/custom/custom_widgets/user_drawer.dart';
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
                ModernGradientAppBar(
                  title: AppLabels.wishlistTitle(context),
                  subtitle: AppLabels.manageInterests(context),

                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildStatusFilter(theme),
                        ),
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
                  _MyWishlistTab(
                    userId: widget.userId,
                    statusFilter: _selectedStatus,
                  ),
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
          _buildFilterChip(null, AppLabels.all(context), theme),
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
          ref
              .read(myWishlistNotifierProvider.notifier)
              .setStatusFilter(_selectedStatus);
          ref
              .read(wishlistedMeNotifierProvider.notifier)
              .setStatusFilter(_selectedStatus);
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
              AppLabels.error(context, wishlistState.error.toString()),
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
              label: Text(AppLabels.retry(context)),
            ),
          ],
        ),
      );
    }

    final wishlists = wishlistState.filteredWishlists;

    if (wishlists.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: AppLabels.emptyWishlistTitle(context),
        subtitle: AppLabels.emptyWishlistSubtitle(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlists.length,
      itemBuilder: (context, index) {
        final wishlist = wishlists[index];
        return WishlistProfileCard(
          wishlist: wishlist,
          profileId: wishlist.receiverId,
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
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
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
              AppLabels.error(context, wishlistState.error.toString()),
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
              label: Text(AppLabels.retry(context)),
            ),
          ],
        ),
      );
    }

    final wishlists = wishlistState.filteredWishlists;

    if (wishlists.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: AppLabels.noOneWishlistedMeTitle(context),
        subtitle: AppLabels.noOneWishlistedMeSubtitle(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlists.length,
      itemBuilder: (context, index) {
        final wishlist = wishlists[index];
        return WishlistProfileCard(
          wishlist: wishlist,
          profileId: wishlist.senderId,
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
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
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
    final locationAsync = ref.watch(locationJsonProvider);
    final profileAsync = ref.watch(matrimonyProfileProvider(profileId));
    final heroTag =
        'wishlist-image-${wishlist.id}-$profileId-${isMyWishlist ? 'my' : 'me'}';

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
            final stateObj = states
                .where((s) => s.name == profile.address.state.en)
                .firstOrNull;
            if (stateObj != null) {
              resolvedState = stateObj.name;
              final cityObj = stateObj.cities
                  .where(
                    (c) =>
                        c.id == profile.address.city.en ||
                        c.name == profile.address.city.en,
                  )
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
                        tag: heroTag,
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
                                  child: BilingualParser(
                                    value: profile.user.fullName.en.isNotEmpty
                                        ? profile.user.fullName
                                        : BilingualValue.empty(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatusBadge(context, wishlist.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.identity.age} ${AppLabels.ageYrs(context)} • ${profile.employment.jobType.isNotEmpty ? profile.employment.jobType : AppLabels.notAvailableShort(context)}',
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
                                    '$resolvedCity, $resolvedState',
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

  Widget _buildStatusBadge(BuildContext context, String status) {
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
        _getStatusLabel(context, status),
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
          AppLabels.updatedAtWithParam(
            context,
            _formatDateTime(context, wishlist.updatedAt),
          ),
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () => _showStatusUpdateDialog(context),
          icon: const Icon(Icons.edit, size: 16),
          label: Text(AppLabels.updateStatus(context)),
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
        title: Text(AppLabels.updateStatus(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WishlistStatus.values.map((status) {
            final isSelected = wishlist.status == status.name;
            return ListTile(
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status.name),
              ),
              title: Text(_getStatusLabel(context, status.name)),
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
                          AppLabels.statusUpdatedTo(
                            context,
                            _getStatusLabel(context, status.name),
                          ),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLabels.failedToUpdateStatus(context, e.toString()),
                        ),
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
            child: Text(AppLabels.cancel(context)),
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
