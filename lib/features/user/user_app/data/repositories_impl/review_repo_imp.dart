import '../datasources/firebase/review_firestore.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/states/review_state.dart';

class ReviewRepoImp implements ReviewRepository {
  final ReviewFirestore _reviewFirestore;

  ReviewRepoImp(this._reviewFirestore);

  @override
  Future<String> addReview(Review review) {
    return _reviewFirestore.addReview(review);
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return _reviewFirestore.deleteReview(reviewId);
  }

  @override
  Future<Review?> getReviewById(String reviewId) {
    return _reviewFirestore.getReviewById(reviewId);
  }

  @override
  Future<void> updateReview(String reviewId, String comment, int rating) {
    return _reviewFirestore.updateReview(reviewId, comment, rating);
  }

  @override
  Stream<List<Review>> watchReviewsByUser(String reviewerId) {
    return _reviewFirestore.watchReviewsByUser(reviewerId);
  }

  @override
  Stream<List<Review>> watchReviewsForUser(String userId) {
    return _reviewFirestore.watchReviewsForUser(userId);
  }

  @override
  Stream<List<Review>> watchAllReviews() {
    return _reviewFirestore.watchAllReviews();
  }           

}
