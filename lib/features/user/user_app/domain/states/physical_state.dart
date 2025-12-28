import 'package:flutter/foundation.dart';

class PhysicalProfile {
  final String height;
  final int weight;
  final String bodyType;
  final String complexion;
  final bool physicallyChallenged;

  PhysicalProfile({
    required this.height,
    required this.weight,
    required this.bodyType,
    required this.complexion,
    required this.physicallyChallenged,
  });

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'complexion': complexion,
      'physicallyChallenged': physicallyChallenged,
    };
  }

  factory PhysicalProfile.fromMap(Map<String, dynamic> map) {
    return PhysicalProfile(
      height: map['height'] as String? ?? '',
      weight: map['weight'] as int? ?? 0,
      bodyType: map['bodyType'] as String? ?? '',
      complexion: map['complexion'] as String? ?? '',
      physicallyChallenged: map['physicallyChallenged'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'PhysicalProfile(height: $height, weight: $weight, bodyType: $bodyType, complexion: $complexion, physicallyChallenged: $physicallyChallenged)';
  }

  PhysicalProfile copyWith({
    String? height,
    int? weight,
    String? bodyType,
    String? complexion,
    bool? physicallyChallenged,
  }) {
    return PhysicalProfile(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bodyType: bodyType ?? this.bodyType,
      complexion: complexion ?? this.complexion,
      physicallyChallenged: physicallyChallenged ?? this.physicallyChallenged,
    );
  }

  factory PhysicalProfile.empty() {
    return PhysicalProfile(
      height: '',
      weight: 0,
      bodyType: '',
      complexion: '',
      physicallyChallenged: false,
    );
  }
}

class PhysicalState {
  final PhysicalProfile? physical;
  final bool isLoading;
  final String? error;

  const PhysicalState({this.physical, this.isLoading = false, this.error});

  PhysicalState copyWith({
    PhysicalProfile? physical,
    bool? isLoading,
    String? error,
  }) {
    return PhysicalState(
      physical: physical ?? this.physical,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static const initial = PhysicalState(
    physical: null,
    isLoading: false,
    error: null,
  );
}
