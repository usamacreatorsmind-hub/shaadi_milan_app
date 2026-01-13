import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/review_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  static final List<ReviewModel> reviews = [
    ReviewModel(
      userName: 'Alice Smith',
      rating: 5,
      comment: 'Excellent service! Highly recommend.',
      date: '26 Oct 2023',
      userImage: 'https://randomuser.me/api/portraits/women/1.jpg',
    ),
    ReviewModel(
      userName: 'Bob Johnson',
      rating: 4,
      comment: 'Good experience overall, minor delay.',
      date: '25 Oct 2023',
      userImage: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    ReviewModel(
      userName: 'Charlie Brown',
      rating: 5,
      comment: 'Very professional and helpful.',
      date: '24 Oct 2023',
      userImage: 'https://randomuser.me/api/portraits/men/2.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 900) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: reviews.isEmpty
          ? Center(
              child: Text("No reviews yet", style: theme.textTheme.titleMedium),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ReviewCard(
                  review: reviews[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReviewDetailsScreen(review: reviews[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
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
                  Hero(
                    tag: review.userImage,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(review.userImage),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      review.userName,
                      style: theme.textTheme.titleSmall?.copyWith(
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
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  review.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
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
  final ReviewModel review;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: review.userImage,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(review.userImage),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review.userName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RatingStars(rating: review.rating),
                  const SizedBox(height: 6),
                  Text(
                    review.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Review",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(review.comment, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
