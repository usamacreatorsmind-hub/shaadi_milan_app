import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_screen.dart';

import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../../../app/custom/custom_widgets/drawer.dart';
import '../../../../../app/custom/custom_widgets/user_drawer.dart';

import '../../../../../app/custom/shimmer.dart';
import '../../../../../app/router/app_router.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import 'my_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

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
                          ? SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.7,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final wishlistedProfileId =
                                    profile.wishlists![index];

                                return Consumer(
                                  builder: (context, ref, child) {
                                    final wishlistedProfileAsync = ref.watch(
                                      matrimonyProfileProvider(
                                        wishlistedProfileId,
                                      ),
                                    );

                                    return wishlistedProfileAsync.when(
                                      loading: () =>
                                          const ShimmerLoading.rectangular(
                                            height: 250,
                                          ),
                                      error: (e, st) => Card(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Could not load profile.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.red.shade300,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      data: (wishlistedProfile) {
                                        return UserCard(
                                          onLongPress: () async {
                                            // show dialog box
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    "Remove from Wishlist?",
                                                  ),
                                                  content: const Text(
                                                    "Are you sure you want to remove this profile from your wishlist?",
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text(
                                                        "Remove",
                                                      ),
                                                      onPressed: () async {
                                                        await ref
                                                            .read(
                                                              userRepositoryProvider,
                                                            )
                                                            .removeWishlist(
                                                              uid:
                                                                  widget.userId,
                                                              profileId:
                                                                  wishlistedProfileId,
                                                            );
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },

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
                                              '${wishlistedProfile.address.city ?? ''}, ${wishlistedProfile.address.state ?? ''}',
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

class UserCard extends StatelessWidget {
  final String uid;
  final String name;
  final int age;
  final String occupation;
  final String location;
  final String imageUrl;
  final VoidCallback onLongPress;

  const UserCard({
    super.key,
    required this.uid,
    required this.name,
    required this.age,
    required this.occupation,
    required this.location,
    required this.imageUrl,
    required this.onLongPress,
  });

  @override
  Widget build(context) {
    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.router.push(UserDetailRoute(uid: uid)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'user-image-$uid',
                    child: imageUrl.isEmpty
                        ? Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$age Yrs, $occupation',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[600],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
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
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              onLongPress();
            },
            child: Icon(
              Icons.cancel_outlined,
              size: 40,
              color: Theme.of(context).canvasColor,
            ),
          ),
        ),
      ],
    );
  }
}
