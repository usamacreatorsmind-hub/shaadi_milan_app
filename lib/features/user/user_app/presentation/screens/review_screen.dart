import 'package:arvika_marriage_bureau/app/custom/custom_widgets/chip_and_action_chip.dart';

import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../../../app/custom/custom_widgets/drawer.dart';
import '../../../../../app/custom/custom_widgets/user_drawer.dart';
import '../../../../../app/router/app_router.dart';
import '../../data/repositories_impl/user_repo_impl.dart';
import '../controllers/review_notifiers.dart';

import '../../domain/states/review_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allReviewsNotifierProvider.notifier).watchAllReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final currentUserAsync = ref.watch(currentUserProvider);
    final allReviewsAsync = ref.watch(allReviewsNotifierProvider);

    int crossAxisCount = 2;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 900) {
      crossAxisCount = 3;
    }

    return Scaffold(
      drawer: UserDrawer(userAsync: currentUserAsync),
      body: allReviewsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : allReviewsAsync.error != null
          ? Center(child: Text('Error: ${allReviewsAsync.error}'))
          : CustomScrollView(
              slivers: [
                MinimalAppBar(
                  title: "Review",
                  actions: [
                    AppActionChip(
                      label: "Write a review",
                      onTap: () =>
                          // if agetn id is empty then no
                          currentUserAsync.value?.agentId == null
                          ? ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "You can't write a review without an agent",
                                ),
                              ),
                            )
                          : context.pushRoute(const ReviewFormRoute()),
                    ),

                    const SizedBox(width: 20),
                  ],
                ),

                /// HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "What our users say about us",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Read genuine reviews from our happy customers.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                /// EMPTY STATE
                if (allReviewsAsync.reviews.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No reviews yet!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Be the first to leave a review!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  /// GRID
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final review = allReviewsAsync.reviews[index];
                        return ReviewCard(
                          review: review,
                          onTap: () {
                            context.pushRoute(
                              ReviewDetailsRoute(review: review),
                            );
                          },
                        );
                      }, childCount: allReviewsAsync.reviews.length),
                    ),
                  ),
              ],
            ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onTap;

  const ReviewCard({super.key, required this.review, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // hero animation
                  Hero(
                    tag: 'review_avatar_${review.id}',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: review.userProfileImg.isNotEmpty
                          ? NetworkImage(review.userProfileImg)
                          : null,
                      child: review.userProfileImg.isEmpty
                          ? const Icon(Icons.person, size: 24)
                          : null,
                    ),
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      review.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RatingStars(rating: review.rating),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  review.comment,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final int rating;
  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        ),
      ),
    );
  }
}

@RoutePage()
class ReviewDetailsScreen extends StatelessWidget {
  final Review review;
  const ReviewDetailsScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Details"),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'review_avatar_${review.id}',

                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: review.userProfileImg.isNotEmpty
                          ? NetworkImage(review.userProfileImg)
                          : null,
                      child: review.userProfileImg.isEmpty
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.userName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reviewed on ${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Center(child: RatingStars(rating: review.rating)),
              const SizedBox(height: 24),
              if (review.title.isNotEmpty) ...[
                Text(
                  "Title",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                "Comment",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                review.comment,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
