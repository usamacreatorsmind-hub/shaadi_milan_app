import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/metrimony_flow_screen.dart';

import '../../../../agent/domain/states/agent_entity.dart';
import 'address_state.dart';
import 'cultural_state.dart';
import 'education_state.dart';
import 'employee_state.dart';
import 'family_state.dart';
import 'identity_state.dart';
import 'lifestyle_state.dart';
import 'physical_state.dart';
import 'user_state.dart';

class MatrimonyProfile {
  final AppUser? user;
  final IdentityProfile? identity;
  final AddressProfile? address;
  final CulturalProfile? cultural;
  final EducationProfile? education;
  final EmploymentProfile? employment;
  final FamilyProfile? family;
  final LifestyleProfile? lifestyle;
  final PhysicalProfile? physical;
  final AgentProfile? agent;
  final ProfileImages? images;

  MatrimonyProfile({
    this.user,
    this.images,
    this.identity,
    this.address,
    this.cultural,
    this.education,
    this.employment,
    this.family,
    this.lifestyle,
    this.physical,
    this.agent,
  });

  @override
  String toString() {
    return 'MatrimonyProfile(user: $user, identity: $identity, address: $address, cultural: $cultural, education: $education, employment: $employment, family: $family, lifestyle: $lifestyle, physical: $physical, agent: $agent, images: $images)';
  }

  factory MatrimonyProfile.empty() {
    return MatrimonyProfile();
  }

  MatrimonyProfile copyWith({
    AppUser? user,
    IdentityProfile? identity,
    AddressProfile? address,
    CulturalProfile? cultural,
    EducationProfile? education,
    EmploymentProfile? employment,
    FamilyProfile? family,
    LifestyleProfile? lifestyle,
    PhysicalProfile? physical,
    AgentProfile? agent,
    ProfileImages? images,
  }) {
    return MatrimonyProfile(
      user: user ?? this.user,
      identity: identity ?? this.identity,
      address: address ?? this.address,
      cultural: cultural ?? this.cultural,
      education: education ?? this.education,
      employment: employment ?? this.employment,
      family: family ?? this.family,
      lifestyle: lifestyle ?? this.lifestyle,
      physical: physical ?? this.physical,
      agent: agent ?? this.agent,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user?.toMap(),
      'identity': identity?.toMap(),
      'address': address?.toMap(),
      'cultural': cultural?.toMap(),
      'education': education?.toMap(),
      'employment': employment?.toMap(),
      'family': family?.toMap(),
      'lifestyle': lifestyle?.toMap(),
      'physical': physical?.toMap(),
      'agent': agent?.toMap(),

      'images': images?.toMap(),
    };
  }

  factory MatrimonyProfile.fromMap(Map<String, dynamic> map) {
    return MatrimonyProfile(
      user: map['user'] != null
          ? AppUser.fromMap(map['user'] as Map<String, dynamic>)
          : null,

      images: map['images'] != null
          ? ProfileImages.fromMap(map['images'] as Map<String, dynamic>)
          : null,

      identity: map['identity'] != null
          ? IdentityProfile.fromMap(map['identity'] as Map<String, dynamic>)
          : null,
      address: map['address'] != null
          ? AddressProfile.fromMap(map['address'] as Map<String, dynamic>)
          : null,
      cultural: map['cultural'] != null
          ? CulturalProfile.fromMap(map['cultural'] as Map<String, dynamic>)
          : null,
      education: map['education'] != null
          ? EducationProfile.fromMap(map['education'] as Map<String, dynamic>)
          : null,
      employment: map['employment'] != null
          ? EmploymentProfile.fromMap(map['employment'] as Map<String, dynamic>)
          : null,
      family: map['family'] != null
          ? FamilyProfile.fromMap(map['family'] as Map<String, dynamic>)
          : null,
      lifestyle: map['lifestyle'] != null
          ? LifestyleProfile.fromMap(map['lifestyle'] as Map<String, dynamic>)
          : null,
      physical: map['physical'] != null
          ? PhysicalProfile.fromMap(map['physical'] as Map<String, dynamic>)
          : null,
      agent: map['agent'] != null
          ? AgentProfile.fromMap(map['agent'] as Map<String, dynamic>)
          : null,
    );
  }
}

/* ============================================================
   =================== FLOW STATE =============================
   ============================================================ */

class MetrimonyState {
  final MatrimonyProfile metrimony;
  final MatrimonyStep step;
  final bool isLoading;
  final String? error;
  final bool isCompleted;

  const MetrimonyState({
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
      isCompleted: false,
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

/* ============================================================
   =================== STEPS ENUM =============================
   ============================================================ */
