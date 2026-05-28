import 'dart:async';

import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/firebase/review_firestore.dart';
import '../../data/repositories_impl/review_repo_imp.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/states/review_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRepository _reviewRepository;
  final String? _currentUserId;

  ReviewNotifier(this._reviewRepository, this._currentUserId)
    : super(ReviewState.initial());

  Future<void> addReview({required Review review}) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _reviewRepository.addReview(review);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required String comment,
    required int rating,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _reviewRepository.updateReview(reviewId, comment, rating);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteReview(String reviewId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _reviewRepository.deleteReview(reviewId);
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reviewNotifierProvider =
    StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
      final reviewRepository = ref.watch(reviewRepositoryProvider);
      final currentUserId = ref
          .watch(authControllerProvider.notifier)
          .currentUserId;
      return ReviewNotifier(reviewRepository, currentUserId);
    });

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepoImp(ref.watch(reviewFirestoreProvider));
});

class AllReviewsNotifier extends StateNotifier<AllReviewsState> {
  final ReviewRepository _reviewRepository;

  AllReviewsNotifier(this._reviewRepository) : super(AllReviewsState.initial());

  Stream<List<Review>>? _reviewsStream;
  StreamSubscription? _reviewsSubscription;

  Future<void> watchReviewsForUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    _reviewsSubscription?.cancel(); // Cancel previous subscription if any

    _reviewsStream = _reviewRepository.watchReviewsForUser(userId);
    _reviewsSubscription = _reviewsStream?.listen(
      (reviews) {
        state = state.copyWith(reviews: reviews, isLoading: false);
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  Future<void> watchReviewsByUser(String reviewerId) async {
    state = state.copyWith(isLoading: true, error: null);
    _reviewsSubscription?.cancel(); // Cancel previous subscription if any

    _reviewsStream = _reviewRepository.watchReviewsByUser(reviewerId);
    _reviewsSubscription = _reviewsStream?.listen(
      (reviews) {
        state = state.copyWith(reviews: reviews, isLoading: false);
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  Future<void> watchAllReviews() async {
    state = state.copyWith(isLoading: true, error: null);
    _reviewsSubscription?.cancel(); // Cancel previous subscription if any

    _reviewsStream = _reviewRepository.watchAllReviews();
    _reviewsSubscription = _reviewsStream?.listen(
      (reviews) {
        state = state.copyWith(reviews: reviews, isLoading: false);
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  @override
  void dispose() {
    _reviewsSubscription?.cancel();
    super.dispose();
  }
}

final allReviewsNotifierProvider =
    StateNotifierProvider<AllReviewsNotifier, AllReviewsState>((ref) {
      final reviewRepository = ref.watch(reviewRepositoryProvider);
      return AllReviewsNotifier(reviewRepository);
    });

final allReviewsStreamProvider = StreamProvider.autoDispose<List<Review>>((
  ref,
) {
  final reviewRepository = ref.watch(reviewRepositoryProvider);
  return reviewRepository.watchAllReviews();
});

final userReviewsStreamProvider = StreamProvider.family
    .autoDispose<List<Review>, String>((ref, userId) {
      final reviewRepository = ref.watch(reviewRepositoryProvider);
      return reviewRepository.watchReviewsForUser(userId);
    });
final reviewsByUserStreamProvider = StreamProvider.family
    .autoDispose<List<Review>, String>((ref, reviewerId) {
      final reviewRepository = ref.watch(reviewRepositoryProvider);
      return reviewRepository.watchReviewsByUser(reviewerId);
    });
