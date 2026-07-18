import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';

class RecommendedProfiles {
  final String userId;
  final BilingualValue name;
  final String phone;
  final BilingualValue gender;
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
      name: BilingualValue.empty(),
      phone: '',
      ids: [],
      gender: BilingualValue.empty(),
      updatedAt: null,
    );
  }

  /// From Map / Firestore
  factory RecommendedProfiles.fromJson(Map<String, dynamic> json) {
    return RecommendedProfiles(
      userId: json['userId']?.toString() ?? '',
      name: json['name'] != null && json['name'] is Map
          ? BilingualValue.fromMap(Map<String, dynamic>.from(json['name']))
          : BilingualValue.empty(),
      phone: json['phone']?.toString() ?? '',
      ids: List<String>.from(json['ids'] ?? []),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,

      gender: json['gender'] ,
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
    BilingualValue? name,
    String? phone,
    List<String>? ids,
    DateTime? updatedAt,
    BilingualValue? gender,
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
