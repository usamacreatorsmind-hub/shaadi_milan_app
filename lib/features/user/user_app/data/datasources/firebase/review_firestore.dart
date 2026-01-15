import '../../../domain/states/review_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// export provider

import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewFirestoreProvider = Provider<ReviewFirestore>((ref) {
  return ReviewFirestore(FirebaseFirestore.instance);
});

class ReviewFirestore {
  final FirebaseFirestore _firestore;

  ReviewFirestore(this._firestore);

  CollectionReference get _reviews => _firestore.collection('reviews');

  /// ADD REVIEW (returns document ID)
  Future<String> addReview(Review review) async {
    final doc = await _reviews.add(review.toMap());
    return doc.id;
  }

  /// STREAM reviews for a user (latest first)
  Stream<List<Review>> watchReviewsForUser(String userId) {
    return _reviews
        .where('reviewedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Review.fromFirestore).toList());
  }

  /// STREAM reviews written by a user
  Stream<List<Review>> watchReviewsByUser(String reviewerId) {
    return _reviews
        .where('reviewerId', isEqualTo: reviewerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Review.fromFirestore).toList());
  }

  /// UPDATE REVIEW
  Future<void> updateReview(String reviewId, String comment, int rating) async {
    await _reviews.doc(reviewId).update({
      'comment': comment,
      'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// DELETE REVIEW
  Future<void> deleteReview(String reviewId) async {
    await _reviews.doc(reviewId).delete();
  }

  /// GET SINGLE REVIEW
  Future<Review?> getReviewById(String reviewId) async {
    final doc = await _reviews.doc(reviewId).get();
    if (!doc.exists) return null;
    return Review.fromFirestore(doc);
  }
  /// STREAM ALL REVIEWS
  Stream<List<Review>> watchAllReviews() {
    return _reviews
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Review.fromFirestore).toList());
  }               


}
