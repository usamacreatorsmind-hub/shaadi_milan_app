import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import 'package:shadi_milan/features/user/user_app/data/repositories_impl/user_repo_impl.dart';

import '../../../../../core/constants/app_labels.dart';
import '../controllers/review_notifiers.dart';

@RoutePage()
class MyReviewScreen extends ConsumerStatefulWidget {
  const MyReviewScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyReviewScreenState();
}

class _MyReviewScreenState extends ConsumerState<MyReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = ref.read(currentUserProvider).value?.uid;
      if (currentUserId != null) {
        ref
            .read(allReviewsNotifierProvider.notifier)
            .watchReviewsByUser(currentUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewState = ref.watch(allReviewsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLabels.myReviews(context)),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: reviewState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviewState.error != null
          ? Center(child: Text(AppLabels.error(context, reviewState.error!)))
          : reviewState.reviews.isEmpty
          ? Center(child: Text(AppLabels.noReviewsYet(context)))
          : ListView.builder(
              itemCount: reviewState.reviews.length,
              itemBuilder: (context, index) {
                final review = reviewState.reviews[index];
                return InkWell(
                  onTap: () {
                    // Handle tap on review, e.g., navigate to edit screen or show details
                    context.router.push(ReviewDetailsRoute(review: review));
                  },

                  child: ListTile(
                    leading: Hero(
                      tag: 'review_avatar_${review.id}',

                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(review.userProfileImg),
                      ),
                    ),
                    title: Text(
                      review.comment,

                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      maxLines: 1,
                      '${review.comment}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    trailing:
                        /// rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),

                    // trailing: IconButton(
                    //   icon: const Icon(Icons.delete),
                    //   onPressed: () async {
                    //     // Implement delete functionality
                    //     await ref
                    //         .read(reviewNotifierProvider.notifier)
                    //         .deleteReview(review.id);
                    //     // Refresh reviews after deletion
                    //     final currentUserId = ref
                    //         .read(currentUserProvider)
                    //         .value
                    //         ?.uid;
                    //     if (currentUserId != null) {
                    //       ref
                    //           .read(allReviewsNotifierProvider.notifier)
                    //           .watchReviewsByUser(currentUserId);
                    //     }
                    //   },
                    // ),
                  ),
                );
              },
            ),
    );
  }
}
