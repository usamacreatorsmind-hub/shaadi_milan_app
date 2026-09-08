import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shadi_milan/app/custom/custom_widgets/shimmer.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/agent/agent_app/presentation/notifier/wishlist_notifier.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import '../../../../../app/router/app_router.dart';
import '../../domain/states/state_city.dart';
import '../widgets/premium_upgrade_bottom_sheet.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../../../user_razorpay/domain/states/payment.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

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
    final myWishlistAsync = ref.watch(myWishlistStreamProvider(widget.userId));
    final wishlistedMeAsync = ref.watch(wishlistedMeStreamProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.primaryColor,
              indicatorWeight: 3,
              labelColor: theme.primaryColor,
              unselectedLabelColor: Colors.black54,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              tabs: [
                Tab(
                  child: wishlistedMeAsync.when(
                    data: (list) => Text("${AppLabels.tabReceived(context)} (${list.where((e) => e.status == 'pending').length})"),
                    loading: () => Text("${AppLabels.tabReceived(context)} (...)"),
                    error: (_, __) => Text(AppLabels.tabReceived(context)),
                  ),
                ),
                Tab(
                  child: wishlistedMeAsync.when(
                    data: (received) => myWishlistAsync.when(
                      data: (sent) {
                        final count =
                            received.where((e) => e.status == 'interested').length + sent.where((e) => e.status == 'interested').length;
                        return Text("${AppLabels.tabAccepted(context)} ($count)");
                      },
                      loading: () => Text("${AppLabels.tabAccepted(context)} (...)"),
                      error: (_, __) => Text(AppLabels.tabAccepted(context)),
                    ),
                    loading: () => Text("${AppLabels.tabAccepted(context)} (...)"),
                    error: (_, __) => Text(AppLabels.tabAccepted(context)),
                  ),
                ),
                Tab(
                  child: wishlistedMeAsync.when(
                    data: (received) => myWishlistAsync.when(
                      data: (sent) {
                        final count =
                            received.where((e) => e.status == 'contacted').length + sent.where((e) => e.status == 'contacted').length;
                        return Text("${AppLabels.tabContacts(context)} ($count)");
                      },
                      loading: () => Text("${AppLabels.tabContacts(context)} (...)"),
                      error: (_, __) => Text(AppLabels.tabContacts(context)),
                    ),
                    loading: () => Text("${AppLabels.tabContacts(context)} (...)"),
                    error: (_, __) => Text(AppLabels.tabContacts(context)),
                  ),
                ),
                Tab(
                  child: myWishlistAsync.when(
                    data: (list) => Text("${AppLabels.tabSent(context)} (${list.where((e) => e.status == 'pending').length})"),
                    loading: () => Text("${AppLabels.tabSent(context)} (...)"),
                    error: (_, __) => Text(AppLabels.tabSent(context)),
                  ),
                ),
                Tab(text: AppLabels.tabMore(context)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _WishlistedMeTab(userId: widget.userId),
                _AcceptedTab(userId: widget.userId),
                _ContactsTab(userId: widget.userId),
                _SentTab(userId: widget.userId),
                _MoreTab(userId: widget.userId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsTab extends ConsumerWidget {
  final String userId;
  const _ContactsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishlistAsync = ref.watch(myWishlistStreamProvider(userId));
    final wishlistedMeAsync = ref.watch(wishlistedMeStreamProvider(userId));

    return myWishlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (myWishlists) {
        return wishlistedMeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (wishlistedMe) {
            final contactedSent = myWishlists.where((w) => w.status == 'contacted').toList();
            final contactedReceived = wishlistedMe.where((w) => w.status == 'contacted').toList();
            final combined = [...contactedSent, ...contactedReceived];
            combined.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            if (combined.isEmpty) {
              return _EmptyState(
                icon: Icons.contact_phone_outlined,
                title: AppLabels.noContactsYet(context),
                subtitle: AppLabels.noContactsSubtitle(context),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: combined.length,
              itemBuilder: (context, index) {
                final wishlist = combined[index];
                final isMeSender = wishlist.senderId == userId;
                final targetId = isMeSender ? wishlist.receiverId : wishlist.senderId;

                return WishlistProfileCard(
                  wishlist: wishlist,
                  profileId: targetId,
                  isMyWishlist: isMeSender,
                  tabType: WishlistTabType.contacts,
                  onStatusUpdate: (_) {},
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SentTab extends ConsumerWidget {
  final String userId;
  const _SentTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishlistAsync = ref.watch(myWishlistStreamProvider(userId));

    return myWishlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (myWishlists) {
        final pendingSent = myWishlists.where((w) => w.status == 'pending').toList();
        pendingSent.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        if (pendingSent.isEmpty) {
          return _EmptyState(
            icon: Icons.send_outlined,
            title: AppLabels.noSentRequests(context),
            subtitle: AppLabels.noSentRequestsSubtitle(context),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingSent.length,
          itemBuilder: (context, index) {
            final wishlist = pendingSent[index];
            return WishlistProfileCard(
              wishlist: wishlist,
              profileId: wishlist.receiverId,
              isMyWishlist: true,
              tabType: WishlistTabType.sent,
              onStatusUpdate: (status) async {
                await ref
                    .read(myWishlistNotifierProvider.notifier)
                    .updateStatus(wishlistId: wishlist.id, status: status, updatedBy: userId);
              },
            );
          },
        );
      },
    );
  }
}

enum _MoreTabType { requests, deleted }

class _MoreTab extends StatefulWidget {
  final String userId;

  const _MoreTab({required this.userId});

  @override
  State<_MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<_MoreTab> {
  _MoreTabType selectedTab = _MoreTabType.requests;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildChip(AppLabels.tabRequests(context), _MoreTabType.requests),
              const SizedBox(width: 12),
              _buildChip(AppLabels.tabDeleted(context), _MoreTabType.deleted),
            ],
          ),
        ),
        Expanded(
          child: selectedTab == _MoreTabType.requests
              ? _AllRequestsList(userId: widget.userId)
              : _DeletedRequestsList(userId: widget.userId),
        ),
      ],
    );
  }

  Widget _buildChip(String label, _MoreTabType type) {
    final isSelected = selectedTab == type;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => selectedTab = type);
      },
      selectedColor: theme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? theme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? theme.primaryColor : Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}

class _AllRequestsList extends ConsumerWidget {
  final String userId;
  const _AllRequestsList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishlistAsync = ref.watch(myWishlistStreamProvider(userId));

    return myWishlistAsync.when(
      data: (sent) {
        sent.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        if (sent.isEmpty) return const Center(child: Text("No sent requests found"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sent.length,
          itemBuilder: (context, index) {
            final wishlist = sent[index];
            return WishlistProfileCard(
              wishlist: wishlist,
              profileId: wishlist.receiverId,
              isMyWishlist: true,
              tabType: WishlistTabType.moreRequests,
              onStatusUpdate: (status) async {
                await ref
                    .read(myWishlistNotifierProvider.notifier)
                    .updateStatus(wishlistId: wishlist.id, status: status, updatedBy: userId);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _DeletedRequestsList extends ConsumerWidget {
  final String userId;
  const _DeletedRequestsList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishlistAsync = ref.watch(myWishlistStreamProvider(userId));

    return myWishlistAsync.when(
      data: (sent) {
        final deletedSent = sent.where((w) => w.status == 'notinterested').toList();

        if (deletedSent.isEmpty) return const Center(child: Text("No declined profiles"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: deletedSent.length,
          itemBuilder: (context, index) {
            final wishlist = deletedSent[index];
            return WishlistProfileCard(
              wishlist: wishlist,
              profileId: wishlist.receiverId,
              isMyWishlist: true,
              tabType: WishlistTabType.moreDeleted,
              onStatusUpdate: (status) async {
                await ref
                    .read(myWishlistNotifierProvider.notifier)
                    .updateStatus(wishlistId: wishlist.id, status: status, updatedBy: userId);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _AcceptedTab extends ConsumerWidget {
  final String userId;

  const _AcceptedTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishlistAsync = ref.watch(myWishlistStreamProvider(userId));
    final wishlistedMeAsync = ref.watch(wishlistedMeStreamProvider(userId));

    return myWishlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (myWishlists) {
        return wishlistedMeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (wishlistedMe) {
            final acceptedSent = myWishlists.where((w) => w.status == 'interested').toList();
            final acceptedReceived = wishlistedMe.where((w) => w.status == 'interested').toList();

            final combinedAccepted = [...acceptedSent, ...acceptedReceived];
            combinedAccepted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            if (combinedAccepted.isEmpty) {
              return _EmptyState(
                icon: Icons.check_circle_outline,
                title: AppLabels.noAcceptedRequests(context),
                subtitle: AppLabels.noAcceptedRequestsSubtitle(context),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        "Accepted Requests (${combinedAccepted.length})",
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: combinedAccepted.length,
                    itemBuilder: (context, index) {
                      final wishlist = combinedAccepted[index];
                      final isMeSender = wishlist.senderId == userId;
                      final targetProfileId = isMeSender ? wishlist.receiverId : wishlist.senderId;

                      return WishlistProfileCard(
                        wishlist: wishlist,
                        profileId: targetProfileId,
                        isMyWishlist: isMeSender,
                        tabType: WishlistTabType.accepted,
                        onStatusUpdate: (newStatus) async {
                          if (isMeSender) {
                            await ref
                                .read(myWishlistNotifierProvider.notifier)
                                .updateStatus(wishlistId: wishlist.id, status: newStatus, updatedBy: userId);
                          } else {
                            await ref
                                .read(wishlistedMeNotifierProvider.notifier)
                                .updateStatus(wishlistId: wishlist.id, status: newStatus, updatedBy: userId);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WishlistedMeTab extends ConsumerWidget {
  final String userId;

  const _WishlistedMeTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistedMeStreamProvider(userId));

    return wishlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (wishlists) {
        // Show only 'pending' in Received tab
        final filteredWishlists = wishlists.where((w) => w.status == 'pending').toList();

        if (filteredWishlists.isEmpty) {
          return _EmptyState(
            icon: Icons.inbox_outlined,
            title: AppLabels.noNewRequests(context),
            subtitle: AppLabels.noNewRequestsSubtitle(context),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    "All Requests (${filteredWishlists.length})",
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredWishlists.length,
                itemBuilder: (context, index) {
                  final wishlist = filteredWishlists[index];
                  return WishlistProfileCard(
                    wishlist: wishlist,
                    profileId: wishlist.senderId,
                    isMyWishlist: false,
                    tabType: WishlistTabType.received,
                    onStatusUpdate: (newStatus) async {
                      await ref
                          .read(wishlistedMeNotifierProvider.notifier)
                          .updateStatus(wishlistId: wishlist.id, status: newStatus, updatedBy: userId);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

enum WishlistTabType { received, accepted, contacts, sent, moreRequests, moreDeleted }

class WishlistProfileCard extends ConsumerWidget {
  final dynamic wishlist;
  final String profileId;
  final bool isMyWishlist;
  final WishlistTabType tabType;
  final Function(String) onStatusUpdate;

  const WishlistProfileCard({
    super.key,
    required this.wishlist,
    required this.profileId,
    required this.isMyWishlist,
    required this.tabType,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationJsonProvider);
    final profileAsync = ref.watch(matrimonyProfileProvider(profileId));
    final paymentState = ref.watch(paymentNotifierProvider(ref.watch(currentUserProvider).value?.uid ?? ''));
    final isPremium = paymentState.status == PayStatus.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      clipBehavior: Clip.antiAlias,
      child: profileAsync.when(
        loading: () => const ShimmerLoading.rectangular(height: 380),
        error: (err, _) => const ListTile(title: Text("Error loading profile")),
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

          final ageHeightJob =
              '${profile.identity.age} yrs, ${_formatHeight(double.tryParse(profile.physical.height.toString()) ?? 0)} • ${profile.employment.jobType} / ...';
          final langCasteLoc =
              '${profile.cultural.languages.map((l) => l.en).join(", ")}, ${profile.cultural.caste.en} • $resolvedCity, $resolvedState...';

          return InkWell(
            onTap: () => context.router.push(UserDetailRoute(uid: profile.user.uid)),
            child: Column(
              children: [
                // Date Only
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatDateOnly(wishlist.updatedAt, context),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // Circular Profile Image
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: ClipOval(
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const ShimmerLoading.rectangular(height: 160, width: 160),
                              errorWidget: (context, url, error) => const Icon(Icons.person, size: 80),
                            )
                          : const Icon(Icons.person, size: 80),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Message Bubble
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomPaint(
                    painter: _BubblePainter(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLabels.interestMessage(context),
                              style: const TextStyle(color: Color(0xFF0369A1), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            AppLabels.moreLabel(context),
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Profile Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.user.fullName.en,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.metrimonyProfile.metrimonyId,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ageHeightJob,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        langCasteLoc,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons based on tabType
                Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: _buildActionButtons(context, ref, isPremium, profile)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isPremium, dynamic profile) {
    if (tabType == WishlistTabType.received) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Decline Button
            InkWell(
              onTap: () => onStatusUpdate('notinterested'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 20, color: Colors.grey.shade400),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLabels.buttonDecline(context),
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            // Accept Button
            InkWell(
              onTap: () => onStatusUpdate('interested'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      AppLabels.buttonAccept(context),
                      style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFF22C55E)]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x4022C55E), blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: const Icon(Icons.check, size: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (tabType == WishlistTabType.accepted || tabType == WishlistTabType.contacts || tabType == WishlistTabType.sent) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: AppLabels.buttonChat(context),
              icon: Icons.chat_bubble_outline_rounded,
              colors: [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
              onPressed: () => _handlePremiumAction(context, isPremium, "Chat", profile),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              label: AppLabels.buttonCall(context),
              icon: Icons.call_outlined,
              colors: [const Color(0xFFFB923C), const Color(0xFFEA580C)],
              onPressed: () => _handlePremiumAction(context, isPremium, "Call", profile),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({required String label, required IconData icon, required List<Color> colors, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: colors.last.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  void _handlePremiumAction(BuildContext context, bool isPremium, String type, dynamic profile) async {
    if (isPremium) {
      if (type == "Chat") {
        // Update status to contacted if not already
        if (wishlist.status != 'contacted' && (tabType == WishlistTabType.accepted || tabType == WishlistTabType.sent)) {
          await onStatusUpdate('contacted');
        }
        // Navigate to chat
        if (context.mounted) {
          context.router.push(UserChatRoomRoute(peerId: profile.user.uid));
        }
      } else if (type == "Call") {
        final phone = profile.user.phone;
        if (phone.isNotEmpty) {
          final url = Uri.parse('tel:$phone');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.errCouldNotLaunchDialer(context))));
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLabels.errPhoneNotAvailable(context))));
          }
        }
      }
    } else {
      // Show Premium Upgrade Bottom Sheet
      showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => const PremiumUpgradeBottomSheet());
    }
  }

  String _formatHeight(double cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return '${cm.round()} cm ($feet\'$inches")';
  }

  String _formatDateOnly(DateTime date, BuildContext context) {
    return DateFormat('d MMM', Localizations.localeOf(context).toString()).format(date);
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Icon(icon, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.3)),
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
              style: TextStyle(color: Colors.grey[500], fontSize: 15, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0F9FF)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    const radius = 12.0;
    const tipWidth = 14.0;
    const tipHeight = 8.0;

    // Start from top-left after the radius
    path.moveTo(radius, tipHeight);

    // Top edge with tip in the middle
    path.lineTo(size.width / 2 - tipWidth / 2, tipHeight);
    path.lineTo(size.width / 2, 0); // The pointy tip
    path.lineTo(size.width / 2 + tipWidth / 2, tipHeight);
    path.lineTo(size.width - radius, tipHeight);

    // Top-right corner
    path.arcToPoint(Offset(size.width, tipHeight + radius), radius: const Radius.circular(radius));

    // Right edge
    path.lineTo(size.width, size.height - radius);

    // Bottom-right corner
    path.arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius));

    // Bottom edge
    path.lineTo(radius, size.height);

    // Bottom-left corner
    path.arcToPoint(Offset(0, size.height - radius), radius: const Radius.circular(radius));

    // Left edge
    path.lineTo(0, tipHeight + radius);

    // Top-left corner
    path.arcToPoint(Offset(radius, tipHeight), radius: const Radius.circular(radius));

    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
