import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/review_state.dart';

abstract class ReviewRepository {
  /// Add a new review
  Future<String> addReview(Review review);

  /// Get a single review by ID
  Future<Review?> getReviewById(String reviewId);

  /// Stream reviews for a specific user (reviews they received)
  Stream<List<Review>> watchReviewsForUser(String userId);

  /// Stream reviews written by a specific user
  Stream<List<Review>> watchReviewsByUser(String reviewerId);

  /// Update an existing review
  Future<void> updateReview(String reviewId, String comment, int rating);

  /// Delete a review
  Future<void> deleteReview(String reviewId);

// stream all review in the collection
  Stream<List<Review>> watchAllReviews();             


}
