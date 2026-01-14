import '../../../../auth/domain/states/agent_state.dart';
import '../../../../auth/domain/states/user_state.dart';
import 'address_state.dart';
import 'cultural_state.dart';
import 'education_state.dart';
import 'employee_state.dart';
import 'family_state.dart';
import 'identity_state.dart';
import 'image_state.dart';
import 'metrimony_state.dart';
import 'physical_state.dart';

class MetrimonyProfileViewModel {
  final MatrimonyProfile metrimonyProfile;
  final UserEntity userProfile;
  final AgentEntity? agentEntity;

  MetrimonyProfileViewModel({
    required this.metrimonyProfile,
    required this.userProfile,
    required this.agentEntity,
  });

  factory MetrimonyProfileViewModel.fromMetrimonyProfile({
    required MatrimonyProfile matrimonyProfile,
    required UserEntity userProfile,
    required AgentEntity? agentEntity,
  }) {
    return MetrimonyProfileViewModel(
      metrimonyProfile: matrimonyProfile,
      userProfile: userProfile,
      agentEntity: agentEntity,
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
  UserEntity get user => userProfile;
  AgentEntity? get agent => agentEntity;

  MetrimonyProfileViewModel copyWith({
    MatrimonyProfile? metrimonyProfile,
    UserEntity? userProfile,
    AgentEntity? AgentEntity,
  }) {
    return MetrimonyProfileViewModel(
      metrimonyProfile: metrimonyProfile ?? this.metrimonyProfile,
      userProfile: userProfile ?? this.userProfile,
      agentEntity: AgentEntity ?? this.agentEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metrimonyProfile': metrimonyProfile.toMap(),
      'userProfile': userProfile.toMap(),
      'agentEntity': agentEntity?.toMap(),
    };
  }

  factory MetrimonyProfileViewModel.fromMap(Map<String, dynamic> map) {
    return MetrimonyProfileViewModel(
      metrimonyProfile: MatrimonyProfile.fromMap(map['metrimonyProfile']),
      userProfile: UserEntity.fromMap(map['userProfile']),
      agentEntity: map['agentEntity'] != null
          ? AgentEntity.fromMap(map['agentEntity'])
          : null,
    );
  }

  @override
  String toString() {
    return 'MetrimonyProfileViewModel(metrimonyProfile: $metrimonyProfile, userProfile: $userProfile, AgentEntity: $AgentEntity)';
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'metrimonyProfile': metrimonyProfile.toMap(),
      'userProfile': userProfile.toMap(),
      'agentEntity': agentEntity?.toMap(),
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
