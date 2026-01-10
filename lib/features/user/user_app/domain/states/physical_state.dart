class PhysicalProfile {
  final double height;
  final double weight;
  final String bodyType;
  final String complexion;
  final bool physicallyChallenged;
  final String? disabilityDetails;

  const PhysicalProfile({
    required this.height,
    required this.weight,
    required this.bodyType,
    required this.complexion,
    required this.physicallyChallenged,
    this.disabilityDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'complexion': complexion,
      'physicallyChallenged': physicallyChallenged,
      'disabilityDetails': disabilityDetails,
    };
  }

  factory PhysicalProfile.fromMap(Map<String, dynamic> map) {
    return PhysicalProfile(
      height: map['height'] is num
          ? (map['height'] as num).toDouble()
          : double.tryParse(map['height']?.toString() ?? '') ?? 0.0,
      weight: map['weight'] is num
          ? (map['weight'] as num).toDouble()
          : double.tryParse(map['weight']?.toString() ?? '') ?? 0.0,
      bodyType: map['bodyType'] as String? ?? '',
      complexion: map['complexion'] as String? ?? '',
      physicallyChallenged: map['physicallyChallenged'] as bool? ?? false,
      disabilityDetails: map['disabilityDetails'] as String?,
    );
  }

  @override
  String toString() {
    return 'PhysicalProfile(height: $height, weight: $weight, bodyType: $bodyType, complexion: $complexion, physicallyChallenged: $physicallyChallenged, disabilityDetails: $disabilityDetails)';
  }

  PhysicalProfile copyWith({
    double? height,
    double? weight,
    String? bodyType,
    String? complexion,
    bool? physicallyChallenged,
    String? disabilityDetails,
  }) {
    return PhysicalProfile(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bodyType: bodyType ?? this.bodyType,
      complexion: complexion ?? this.complexion,
      physicallyChallenged: physicallyChallenged ?? this.physicallyChallenged,
      disabilityDetails: disabilityDetails ?? this.disabilityDetails,
    );
  }

  factory PhysicalProfile.empty() {
    return PhysicalProfile(
      height: 0.0,
      weight: 0.0,
      bodyType: '',
      complexion: '',
      physicallyChallenged: false,
      disabilityDetails: null,
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
