import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/address_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/cultural_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/education_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/employee_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/family_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/identity_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart'; 
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/physical_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/user_state.dart';

class MetrimonyProfileViewModel {
  final MatrimonyProfile metrimonyProfile;
  final AppUser userProfile;
  final AgentProfile? agentProfile;

  MetrimonyProfileViewModel({
    required this.metrimonyProfile,
    required this.userProfile,
    this.agentProfile,
  });

  factory MetrimonyProfileViewModel.fromMetrimonyProfile({
    required MatrimonyProfile matrimonyProfile,
    required AppUser userProfile,
    AgentProfile? agentProfile,
  }) {
    return MetrimonyProfileViewModel(
      metrimonyProfile: matrimonyProfile,
      userProfile: userProfile,
      agentProfile: agentProfile,
    );
  }

  // Getters for easier access to nested data
  IdentityProfile get identity => metrimonyProfile.identity;
  AddressProfile get address => metrimonyProfile.address;
  CulturalProfile get cultural => metrimonyProfile.cultural;
  EducationProfile get education => metrimonyProfile.education;
  EmploymentProfile get employment => metrimonyProfile.employment;
  FamilyProfile get family => metrimonyProfile.family; 
  PhysicalProfile get physical => metrimonyProfile.physical;
  ProfileImages get images => metrimonyProfile.images;
  AppUser get user => userProfile;
  AgentProfile? get agent => agentProfile;

  MetrimonyProfileViewModel copyWith({
    MatrimonyProfile? metrimonyProfile,
    AppUser? userProfile,
    AgentProfile? agentProfile,
  }) {
    return MetrimonyProfileViewModel(
      metrimonyProfile: metrimonyProfile ?? this.metrimonyProfile,
      userProfile: userProfile ?? this.userProfile,
      agentProfile: agentProfile ?? this.agentProfile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metrimonyProfile': metrimonyProfile.toMap(),
      'userProfile': userProfile.toMap(),
      'agentProfile': agentProfile?.toMap(),
    };
  }

  factory MetrimonyProfileViewModel.fromMap(Map<String, dynamic> map) {
    return MetrimonyProfileViewModel(
      metrimonyProfile: MatrimonyProfile.fromMap(map['metrimonyProfile']),
      userProfile: AppUser.fromMap(map['userProfile']),
      agentProfile: map['agentProfile'] != null
          ? AgentProfile.fromMap(map['agentProfile'])
          : null,
    );
  }

  @override
  String toString() {
    return 'MetrimonyProfileViewModel(metrimonyProfile: $metrimonyProfile, userProfile: $userProfile, agentProfile: $agentProfile)';
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'metrimonyProfile': metrimonyProfile.toMap(),
      'userProfile': userProfile.toMap(),
      'agentProfile': agentProfile?.toMap(),
    };
  }
}

// state

class MetrimonyProfileViewModelState {
  final MetrimonyProfileViewModel? matrimonyProfileViewModel;
  final bool isLoading;
  final String? error;

  const MetrimonyProfileViewModelState({
    this.matrimonyProfileViewModel,
    this.isLoading = false,
    this.error,
  });

  MetrimonyProfileViewModelState copyWith({
    MetrimonyProfileViewModel? matrimonyProfileViewModel,
    bool? isLoading,
    String? error,
  }) {
    return MetrimonyProfileViewModelState(
      matrimonyProfileViewModel:
          matrimonyProfileViewModel ?? this.matrimonyProfileViewModel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory MetrimonyProfileViewModelState.initial() =>
      const MetrimonyProfileViewModelState();
}
