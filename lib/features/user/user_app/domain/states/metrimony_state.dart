import 'agent_state.dart';
import 'home_state.dart';
import 'image_state.dart';
import '../../presentation/screens/metrimony_flow_screen.dart';

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
    this.identity,
    this.address,
    this.cultural,
    this.education,
    this.employment,
    this.family,
    this.lifestyle,
    this.physical,
    this.agent,
    this.images,
  });

  factory MatrimonyProfile.empty() => MatrimonyProfile();

  @override
  String toString() {
    return 'MatrimonyProfile(user: $user, identity: $identity, address: $address, '
        'cultural: $cultural, education: $education, employment: $employment, '
        'family: $family, lifestyle: $lifestyle, physical: $physical, '
        'agent: $agent, images: $images)';
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

  /// ================== 🔥 SAFE FROM MAP 🔥 ==================
  factory MatrimonyProfile.fromMap(Map<String, dynamic> map) {
    try {
      return MatrimonyProfile(
        user: map['user'] != null
            ? AppUser.fromMap(Map<String, dynamic>.from(map['user']))
            : null,

        identity: map['identity'] != null
            ? IdentityProfile.fromMap(
                Map<String, dynamic>.from(map['identity']),
              )
            : null,

        address: map['address'] != null
            ? AddressProfile.fromMap(Map<String, dynamic>.from(map['address']))
            : null,

        cultural: map['cultural'] != null
            ? CulturalProfile.fromMap(
                Map<String, dynamic>.from(map['cultural']),
              )
            : null,

        education: map['education'] != null
            ? EducationProfile.fromMap(
                Map<String, dynamic>.from(map['education']),
              )
            : null,

        employment: map['employment'] != null
            ? EmploymentProfile.fromMap(
                Map<String, dynamic>.from(map['employment']),
              )
            : null,

        family: map['family'] != null
            ? FamilyProfile.fromMap(Map<String, dynamic>.from(map['family']))
            : null,

        /// 🔥 CRITICAL FIX — MERGE ROOT HOBBIES INTO LIFESTYLE
        lifestyle: map['lifestyle'] != null
            ? LifestyleProfile.fromMap({
                ...Map<String, dynamic>.from(map['lifestyle']),
                'hobbies': map['hobbies'] ?? [],
              })
            : null,

        physical: map['physical'] != null
            ? PhysicalProfile.fromMap(
                Map<String, dynamic>.from(map['physical']),
              )
            : null,

        agent: map['agent'] != null
            ? AgentProfile.fromMap(Map<String, dynamic>.from(map['agent']))
            : null,

        images: map['images'] != null
            ? ProfileImages.fromMap(Map<String, dynamic>.from(map['images']))
            : null,
      );
    } catch (e) {
      // 🔥 THIS MAKES DEBUGGING EASY
      throw Exception('❌ MatrimonyProfile.fromMap failed → $e\nData: $map');
    }
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
