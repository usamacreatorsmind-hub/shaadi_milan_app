import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendedProfiles {
  final String userId;
  final String name;
  final String phone;
  final String gender;
  final List<String> ids;
  final DateTime? updatedAt;

  RecommendedProfiles({
    required this.userId,
    required this.name,
    required this.phone,
    required this.ids,
    required this.gender,
    this.updatedAt,
  });

  /// Empty factory
  factory RecommendedProfiles.empty() {
    return RecommendedProfiles(
      userId: '',
      name: '',
      phone: '',
      ids: [],
      gender: '',
      updatedAt: null,
    );
  }

  /// From Map / Firestore
  factory RecommendedProfiles.fromJson(Map<String, dynamic> json) {
    return RecommendedProfiles(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      ids: List<String>.from(json['ids'] ?? []),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,

      gender: json['gender']?.toString() ?? '',
    );
  }

  /// To Map / Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'ids': ids,
      'gender': gender,
      'updatedAt': updatedAt,
    };
  }

  /// CopyWith
  RecommendedProfiles copyWith({
    String? userId,
    String? name,
    String? phone,
    List<String>? ids,
    DateTime? updatedAt,
    String? gender,
  }) {
    return RecommendedProfiles(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      ids: ids ?? this.ids,
      gender: gender ?? this.gender,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RecommendedProfiles('
        'userId: $userId, '
        'name: $name, '
        'phone: $phone, '
        'updatedAt: $updatedAt, '
        'ids: $ids, '
        'gender: $gender'
        ')';
  }
}

class RecommendedProfilesState {
  final List<RecommendedProfiles> profiles;
  final bool isLoading;
  final String? error;

  const RecommendedProfilesState({
    this.profiles = const [],
    this.isLoading = false,
    this.error,
  });

  RecommendedProfilesState copyWith({
    List<RecommendedProfiles>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return RecommendedProfilesState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
