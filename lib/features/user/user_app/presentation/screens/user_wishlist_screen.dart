import 'package:arvika_marriage_bureau/app/custom/custom_widgets/chip_and_action_chip.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../../../app/custom/custom_widgets/user_drawer.dart';
import '../../../../../app/custom/shimmer.dart';
import '../../../../../app/router/app_router.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import 'my_profile_screen.dart';

@RoutePage()
class UserWishListScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserWishListScreen({super.key, required this.userId});

  @override
  ConsumerState<UserWishListScreen> createState() => _UserWishListScreenState();
}

class _UserWishListScreenState extends ConsumerState<UserWishListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentUserAsync = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    // Watch payment status asynchronously
    final paymentState = ref.watch(paymentNotifierProvider(widget.userId));

    return Scaffold(
      drawer: UserDrawer(userAsync: profileAsync),
      backgroundColor: Colors.grey[100],

      body: paymentState.status == PayStatus.success
          ? profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (profile) {
                return CustomScrollView(
                  slivers: [
                    const MinimalAppBar(title: "My WishList"),

                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver:
                          (profile?.wishlists != null &&
                              profile!.wishlists!.isNotEmpty)
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final wishlistedProfileId =
                                    profile.wishlists[index];
                                final status = wishlistedProfileId.status;

                                return Consumer(
                                  builder: (context, ref, _) {
                                    final wishlistedProfileAsync = ref.watch(
                                      matrimonyProfileProvider(
                                        wishlistedProfileId.profileId,
                                      ),
                                    );

                                    return wishlistedProfileAsync.when(
                                      loading: () => const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: ShimmerLoading.rectangular(
                                          height: 90,
                                        ),
                                      ),
                                      error: (_, __) => const ListTile(
                                        title: Text('Could not load profile'),
                                      ),
                                      data: (wishlistedProfile) {
                                        return UserListTile(
                                          status: status,
                                          uid: wishlistedProfile.user.uid ?? '',
                                          name:
                                              wishlistedProfile.user.fullName ??
                                              'N/A',
                                          age:
                                              wishlistedProfile.identity.age ??
                                              0,
                                          occupation:
                                              wishlistedProfile
                                                  .employment
                                                  .jobType ??
                                              'N/A',
                                          location:
                                              '${wishlistedProfile.address.city ?? ''}, '
                                              '${wishlistedProfile.address.state ?? ''}',
                                          imageUrl:
                                              wishlistedProfile
                                                  .images
                                                  .primaryImageUrl ??
                                              '',
                                        );
                                      },
                                    );
                                  },
                                );
                              }, childCount: profile.wishlists!.length),
                            )
                          : SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Your wishlist is empty!",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Start adding profiles to your wishlist to see them here.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            )
          : UserPaymentScreen(userId: currentUserAsync.value?.uid ?? "N/A"),
    );
  }
}

class UserListTile extends StatelessWidget {
  final String uid;
  final String name;
  final int age;
  final String occupation;
  final String location;
  final String status;
  final String imageUrl;

  const UserListTile({
    super.key,
    required this.uid,
    required this.status,

    required this.name,
    required this.age,
    required this.occupation,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => context.router.push(UserDetailRoute(uid: uid)),

        // 👤 Profile Image
        leading: Hero(
          tag: 'user-image-$uid',
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl.isEmpty
                ? Icon(Icons.person, color: Colors.grey.shade500)
                : null,
          ),
        ),

        // 🧾 Name
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            AppActionChip(label: status),
          ],
        ),

        // ℹ Details
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '$age Yrs • $occupation',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
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
    );
  }
}
