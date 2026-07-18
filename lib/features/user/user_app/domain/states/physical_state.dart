import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';

class PhysicalProfile {
  final double height;
  final double weight;
  final BilingualValue bodyType;
  final BilingualValue complexion;
  final bool physicallyChallenged;
  final BilingualValue? disabilityDetails;

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
      'bodyType': bodyType.toMap(),
      'complexion': complexion.toMap(),
      'physicallyChallenged': physicallyChallenged,
      'disabilityDetails': disabilityDetails?.toMap(),
    };
  }

  factory PhysicalProfile.fromMap(Map<String, dynamic> map) {
    BilingualValue parseBilingual(dynamic val) {
      if (val is Map) {
        return BilingualValue.fromMap(Map<String, dynamic>.from(val));
      }
      return BilingualValue(en: val?.toString() ?? '', hi: '');
    }

    return PhysicalProfile(
      height: map['height'] is num
          ? (map['height'] as num).toDouble()
          : double.tryParse(map['height']?.toString() ?? '') ?? 0.0,
      weight: map['weight'] is num
          ? (map['weight'] as num).toDouble()
          : double.tryParse(map['weight']?.toString() ?? '') ?? 0.0,
      bodyType: parseBilingual(map['bodyType']),
      complexion: parseBilingual(map['complexion']),
      physicallyChallenged: map['physicallyChallenged'] as bool? ?? false,
      disabilityDetails: map['disabilityDetails'] != null
          ? parseBilingual(map['disabilityDetails'])
          : null,
    );
  }

  @override
  String toString() {
    return 'PhysicalProfile(height: $height, weight: $weight, bodyType: $bodyType, complexion: $complexion, physicallyChallenged: $physicallyChallenged, disabilityDetails: $disabilityDetails)';
  }

  PhysicalProfile copyWith({
    double? height,
    double? weight,
    BilingualValue? bodyType,
    BilingualValue? complexion,
    bool? physicallyChallenged,
    BilingualValue? disabilityDetails,
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
      bodyType: BilingualValue.empty(),
      complexion: BilingualValue.empty(),
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
