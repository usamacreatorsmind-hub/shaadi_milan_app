import 'agent_state.dart';
import 'home_state.dart';
import 'image_state.dart';
import 'user_state.dart';
import '../../presentation/screens/metrimony_flow_screen.dart';

import 'address_state.dart';
import 'cultural_state.dart';
import 'education_state.dart';
import 'employee_state.dart';
import 'family_state.dart';
import 'identity_state.dart';
import 'lifestyle_state.dart';
import 'physical_state.dart';

/// ============================================================
/// =================== MATRIMONY PROFILE ======================
/// ============================================================

class MatrimonyProfile {
  final String userId;
  final String agentId;

  final IdentityProfile identity;
  final AddressProfile address;
  final CulturalProfile cultural;
  final EducationProfile education;
  final EmploymentProfile employment;
  final FamilyProfile family;
  final LifestyleProfile lifestyle;
  final PhysicalProfile physical;

  final ProfileImages images;

  MatrimonyProfile({
    this.userId = '',
    this.agentId = '',
    IdentityProfile? identity,
    AddressProfile? address,
    CulturalProfile? cultural,
    EducationProfile? education,
    EmploymentProfile? employment,
    FamilyProfile? family,
    LifestyleProfile? lifestyle,
    PhysicalProfile? physical,
    ProfileImages? images,
  }) : identity = identity ?? IdentityProfile.empty(),
       address = address ?? AddressProfile.empty(),
       cultural = cultural ?? CulturalProfile.empty(),
       education = education ?? EducationProfile.empty(),
       employment = employment ?? EmploymentProfile.empty(),
       family = family ?? FamilyProfile.empty(),
       lifestyle = lifestyle ?? LifestyleProfile.empty(),
       physical = physical ?? PhysicalProfile.empty(),
       images = images ?? ProfileImages.empty();

  factory MatrimonyProfile.empty() => MatrimonyProfile();

  /// ---------------- COPY WITH ----------------

  MatrimonyProfile copyWith({
    String? userId,
    String? agentId,
    IdentityProfile? identity,
    AddressProfile? address,
    CulturalProfile? cultural,
    EducationProfile? education,
    EmploymentProfile? employment,
    FamilyProfile? family,
    LifestyleProfile? lifestyle,
    PhysicalProfile? physical,
    ProfileImages? images,
  }) {
    return MatrimonyProfile(
      userId: userId ?? this.userId,
      agentId: agentId ?? this.agentId,
      identity: identity ?? this.identity,
      address: address ?? this.address,
      cultural: cultural ?? this.cultural,
      education: education ?? this.education,
      employment: employment ?? this.employment,
      family: family ?? this.family,
      lifestyle: lifestyle ?? this.lifestyle,
      physical: physical ?? this.physical,
      images: images ?? this.images,
    );
  }

  /// ---------------- TO MAP ----------------

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'agentId': agentId,
      'identity': identity.toMap(),
      'address': address.toMap(),
      'cultural': cultural.toMap(),
      'education': education.toMap(),
      'employment': employment.toMap(),
      'family': family.toMap(),
      'lifestyle': lifestyle.toMap(),
      'physical': physical.toMap(),
      'images': images.toMap(),
    };
  }

  /// ---------------- FROM MAP ----------------

  factory MatrimonyProfile.fromMap(Map<String, dynamic> map) {
    try {
      return MatrimonyProfile(
        userId: map['userId'] ?? '',
        agentId: map['agentId'] ?? '',

        identity: map['identity'] != null
            ? IdentityProfile.fromMap(
                Map<String, dynamic>.from(map['identity']),
              )
            : IdentityProfile.empty(),

        address: map['address'] != null
            ? AddressProfile.fromMap(Map<String, dynamic>.from(map['address']))
            : AddressProfile.empty(),

        cultural: map['cultural'] != null
            ? CulturalProfile.fromMap(
                Map<String, dynamic>.from(map['cultural']),
              )
            : CulturalProfile.empty(),

        education: map['education'] != null
            ? EducationProfile.fromMap(
                Map<String, dynamic>.from(map['education']),
              )
            : EducationProfile.empty(),

        employment: map['employment'] != null
            ? EmploymentProfile.fromMap(
                Map<String, dynamic>.from(map['employment']),
              )
            : EmploymentProfile.empty(),

        /// 🔥 merge root-level hobbies safely
        lifestyle: map['lifestyle'] != null
            ? LifestyleProfile.fromMap({
                ...Map<String, dynamic>.from(map['lifestyle'] ?? {}),
                'hobbies': map['hobbies'] ?? [],
              })
            : LifestyleProfile.empty(),

        physical: map['physical'] != null
            ? PhysicalProfile.fromMap(
                Map<String, dynamic>.from(map['physical']),
              )
            : PhysicalProfile.empty(),

        images: map['images'] != null
            ? ProfileImages.fromMap(Map<String, dynamic>.from(map['images']))
            : ProfileImages.empty(),
      );
    } catch (e) {
      throw Exception('❌ MatrimonyProfile.fromMap failed → $e\nData: $map');
    }
  }

  @override
  String toString() {
    return '''
MatrimonyProfile(
  userId: $userId,
  agentId: $agentId,
  identity: $identity,
  address: $address,
  cultural: $cultural,
  education: $education,
  employment: $employment,
  family: $family,
  lifestyle: $lifestyle,
  physical: $physical,
  images: $images
)
''';
  }
}

/// ============================================================
/// =================== VIEW MODEL =============================
/// ============================================================

class MatrimonyProfileViewModel {
  final MatrimonyProfile profile;
  final AppUser? user;
  final AgentProfile? agent;

  const MatrimonyProfileViewModel({
    required this.profile,
    this.user,
    this.agent,
  });

  factory MatrimonyProfileViewModel.empty() =>
      MatrimonyProfileViewModel(profile: MatrimonyProfile.empty());
}

/// ============================================================
/// =================== FLOW STATE =============================
/// ============================================================

class MetrimonyState {
  final MatrimonyProfile metrimony;
  final MatrimonyStep step;
  final bool isLoading;
  final String? error;
  final bool isCompleted;

  MetrimonyState({
    required this.metrimony,
    required this.step,
    this.isLoading = false,
    this.error,
    this.isCompleted = false,
  });

  factory MetrimonyState.initial() {
    return MetrimonyState(
      metrimony: MatrimonyProfile.empty(),
      step: MatrimonyStep.identity,
    );
  }

  MetrimonyState copyWith({
    MatrimonyProfile? metrimony,
    MatrimonyStep? step,
    bool? isLoading,
    String? error,
    bool? isCompleted,
  }) {
    return MetrimonyState(
      metrimony: metrimony ?? this.metrimony,
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
