import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/custom/custom_widgets/shimmer.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/wishlist_notifier.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';
import '../../../../../../core/constants/app_labels.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../auth/domain/states/user_state.dart';
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
    final paymentState = ref.watch(paymentNotifierProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: paymentState.status == PayStatus.idle
          ? NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(top: 8),
                    color: Colors.white,
                    child: Column(children: [_buildStatusFilter(theme), const SizedBox(height: 8)]),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: theme.primaryColor,
                      labelColor: theme.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(text: AppLabels.myWishlist(context)),
                        Tab(text: AppLabels.wishlistedMe(context)),
                      ],
                    ),
                  ),
                ),
              ],
              body: Container(
                color: Colors.grey[50],
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _MyWishlistTab(userId: widget.userId, statusFilter: _selectedStatus),
                    _WishlistedMeTab(userId: widget.userId, statusFilter: _selectedStatus),
                  ],
                ),
              ),
            )
          : UserPaymentScreen(userId: widget.userId),
    );
  }

  Widget _buildStatusFilter(ThemeData theme) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatus = isSelected ? null : status;
          });
          ref.read(myWishlistNotifierProvider.notifier).setStatusFilter(_selectedStatus);
          ref.read(wishlistedMeNotifierProvider.notifier).setStatusFilter(_selectedStatus);
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey.shade300, width: 1.5),
            boxShadow: isSelected
                ? [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Icon(icon, size: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 15, height: 1.5),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Icon(icon, size: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 15, height: 1.5),
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: profileAsync.when(
        loading: () => const ShimmerLoading.rectangular(height: 180),
        error: (err, _) => ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
            child: const Icon(Icons.error_outline, color: Colors.red),
          ),
          title: Text(AppLabels.couldNotLoadProfile(context), style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${AppLabels.profileId(context)}: $profileId'),
        ),
        data: (profile) {
          final imageUrl = profile.images.primaryImageUrl.isNotEmpty
              ? profile.images.primaryImageUrl
              : (profile.images.profileImageUrl.isNotEmpty ? profile.images.profileImageUrl : '');
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
            onTap: () => context.router.push(UserDetailRoute(uid: profile.user.uid)),
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
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasImage
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const ShimmerLoading.rectangular(height: 90, width: 90),
                                  errorWidget: (context, url, error) => Container(
                                    color: theme.primaryColor.withValues(alpha: 0.05),
                                    child: Icon(Icons.person, color: theme.primaryColor, size: 40),
                                  ),
                                )
                              : Container(
                                  color: theme.primaryColor.withValues(alpha: 0.05),
                                  child: Icon(Icons.person, color: theme.primaryColor, size: 40),
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
                                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatusBadge(context, wishlist.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                '${profile.identity.age} ${AppLabels.ageYrs(context)} • ${profile.employment.jobType.isNotEmpty ? profile.employment.jobType : AppLabels.notAvailableShort(context)}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 16, color: theme.primaryColor.withValues(alpha: 0.7)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '$resolvedCity, $resolvedState',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[100]!)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.update_rounded, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(context, wishlist.updatedAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showStatusUpdateDialog(context),
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: Text(AppLabels.updateStatus(context), style: const TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} mins ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
