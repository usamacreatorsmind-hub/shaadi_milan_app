import '../../../../auth/domain/states/agent_state.dart';
import '../../../../auth/domain/states/user_state.dart';

import 'image_state.dart';
import '../../presentation/screens/metrimony_flow_screen.dart';

import 'address_state.dart';
import 'cultural_state.dart';
import 'education_state.dart';
import 'employee_state.dart';
import 'family_state.dart';
import 'identity_state.dart';
import 'physical_state.dart';

/// ============================================================
/// =================== MATRIMONY PROFILE ======================
/// ============================================================

class MatrimonyProfile {
  final String userId;
  final String metrimonyId;
  final IdentityProfile identity;
  final AddressProfile address;
  final CulturalProfile cultural;
  final EducationProfile education;
  final EmploymentProfile employment;
  final FamilyProfile family;
  final PhysicalProfile physical;
  final ProfileImages images;
  final String profileStatus;

  MatrimonyProfile({
    this.metrimonyId = "",

    required this.profileStatus,

    this.userId = '',

    IdentityProfile? identity,
    AddressProfile? address,
    CulturalProfile? cultural,
    EducationProfile? education,
    EmploymentProfile? employment,
    FamilyProfile? family,
    PhysicalProfile? physical,
    ProfileImages? images,
  }) : identity = identity ?? IdentityProfile.empty(),
       address = address ?? AddressProfile.empty(),
       cultural = cultural ?? CulturalProfile.empty(),
       education = education ?? EducationProfile.empty(),
       employment = employment ?? EmploymentProfile.empty(),
       family = family ?? FamilyProfile.empty(),
       physical = physical ?? PhysicalProfile.empty(),
       images = images ?? ProfileImages.empty();

  factory MatrimonyProfile.empty() => MatrimonyProfile(
    userId: '',
    metrimonyId: '',
    profileStatus: 'active',

    identity: IdentityProfile.empty(),
    address: AddressProfile.empty(),
    cultural: CulturalProfile.empty(),
    education: EducationProfile.empty(),

    employment: EmploymentProfile.empty(),
    family: FamilyProfile.empty(),
    physical: PhysicalProfile.empty(),
    images: ProfileImages.empty(),
  );

  /// ---------------- COPY WITH ----------------

  MatrimonyProfile copyWith({
    String? metrimonyId,
    String? profileStatus,

    String? userId,
    IdentityProfile? identity,
    AddressProfile? address,
    CulturalProfile? cultural,
    EducationProfile? education,
    EmploymentProfile? employment,
    FamilyProfile? family,
    PhysicalProfile? physical,
    ProfileImages? images,
  }) {
    return MatrimonyProfile(
      metrimonyId: metrimonyId ?? this.metrimonyId,
      profileStatus: profileStatus ?? this.profileStatus,

      userId: userId ?? this.userId,
      identity: identity ?? this.identity,
      address: address ?? this.address,
      cultural: cultural ?? this.cultural,
      education: education ?? this.education,
      employment: employment ?? this.employment,
      family: family ?? this.family,
      physical: physical ?? this.physical,
      images: images ?? this.images,
    );
  }

  /// ---------------- TO MAP ----------------

  Map<String, dynamic> toMap() {
    return {
      "metrimonyId": metrimonyId,
      "profileStatus": profileStatus,

      'userId': userId,
      'identity': identity.toMap(),
      'address': address.toMap(),
      'cultural': cultural.toMap(),
      'education': education.toMap(),
      'employment': employment.toMap(),
      'family': family.toMap(),
      'physical': physical.toMap(),
      'images': images.toMap(),
    };
  }

  /// ---------------- FROM MAP ----------------

  factory MatrimonyProfile.fromMap(Map<String, dynamic> map) {
    try {
      return MatrimonyProfile(
        metrimonyId: map['metrimonyId'] ?? '',
        profileStatus: map['profileStatus'] ?? 'active',

        userId: map['userId'] ?? '',

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

        family: map['family'] != null
            ? FamilyProfile.fromMap(Map<String, dynamic>.from(map['family']))
            : FamilyProfile.empty(),

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
  profileStatus: $profileStatus, 
  metrimonyId: $metrimonyId,
  userId: $userId, 
  identity: $identity,
  address: $address,
  cultural: $cultural,
  education: $education,
  employment: $employment,
  family: $family, 
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
  final UserEntity? user;
  final AgentEntity? agent;

  const MatrimonyProfileViewModel({
    required this.profile,
    required this.user,
    required this.agent,
  });

  // copy with
  MatrimonyProfileViewModel copyWith({
    MatrimonyProfile? profile,
    UserEntity? user,
    AgentEntity? agent,
  }) {
    return MatrimonyProfileViewModel(
      profile: profile ?? this.profile,
      user: user ?? this.user,
      agent: agent ?? this.agent,
    );
  }

  factory MatrimonyProfileViewModel.empty() => MatrimonyProfileViewModel(
    profile: MatrimonyProfile.empty(),
    user: UserEntity.empty(),
    agent: AgentEntity.empty(),
  );
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
