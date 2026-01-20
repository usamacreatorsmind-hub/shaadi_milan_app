import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/scroll_view.dart';

class Review {
  final String id;
  final String title;
  final String comment;
  final String agentId;
  final int rating;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final String userName;
  final String userProfileImg;

  Review({
    required this.agentId,
    required this.id,
    required this.title,
    required this.comment,
    required this.rating,
    required this.createdAt,
    this.updatedAt,
    required this.userProfileImg,
    required this.userId,
    required this.userName,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      agentId: data['agentId'] ?? '',

      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userProfileImg: data['userProfileImg'] ?? '',
      title: data['title'] ?? '',

      comment: data['comment'],
      rating: data['rating'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agentId': agentId,

      'title': title,
      'userId': userId,
      'userName': userName,
      'userProfileImg': userProfileImg,
      'comment': comment,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? FieldValue.serverTimestamp() : null,
    };
  }
}

class ReviewState {
  final Review? review;
  final bool isLoading;
  final String? error;

  const ReviewState({this.review, this.isLoading = false, this.error});

  ReviewState copyWith({Review? review, bool? isLoading, String? error}) {
    return ReviewState(
      review: review ?? this.review,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory ReviewState.initial() => const ReviewState();
}

class AllReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;

  const AllReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  AllReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return AllReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory AllReviewsState.initial() => const AllReviewsState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllReviewsState &&
          runtimeType == other.runtimeType &&
          reviews == other.reviews &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => reviews.hashCode ^ isLoading.hashCode ^ error.hashCode;
}
