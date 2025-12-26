import 'package:arvika_marriage_bureau/app/custom/shimmer.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/my_profile_screen.dart';
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

    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (profile) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.grey[100],
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  centerTitle: false,
                  title: Text(
                    "My Wishlist",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
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
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final wishlistedProfileId = profile.wishlists![index];

                          return Consumer(
                            builder: (context, ref, child) {
                              final wishlistedProfileAsync = ref.watch(
                                matrimonyProfileProvider(wishlistedProfileId),
                              );

                              return wishlistedProfileAsync.when(
                                loading: () => const ShimmerLoading.rectangular(
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
                                    uid: wishlistedProfile.user?.uid ?? '',
                                    name:
                                        wishlistedProfile.user?.fullName ??
                                        'N/A',
                                    age: wishlistedProfile.identity?.age ?? 0,
                                    occupation:
                                        wishlistedProfile.employment?.jobType ??
                                        'N/A',
                                    location:
                                        '${wishlistedProfile.address?.city ?? ''}, ${wishlistedProfile.address?.state ?? ''}',
                                    imageUrl:
                                        wishlistedProfile
                                            .images
                                            ?.primaryImageUrl ??
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
      ),
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

  const UserCard({
    super.key,
    required this.uid,
    required this.name,
    required this.age,
    required this.occupation,
    required this.location,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.router.push(UserDetailRoute(uid: uid)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
                        return const Center(child: CircularProgressIndicator());
                      },
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
    );
  }
}
