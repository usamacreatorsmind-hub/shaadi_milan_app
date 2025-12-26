import '../../../../agent/domain/states/agent_entity.dart';
import '../../data/datasources/firebase/agent_firestore_ds.dart';
import '../../data/datasources/firebase/metrimony_firestore.dart';
import '../../data/datasources/firebase/user_status_firestore.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../data/repositories_impl/userstatus_repository.dart';
import '../../domain/repositories/user_status_repository.dart';
import '../../domain/states/agent_state.dart';
import '../../domain/states/image_state.dart';
import '../../domain/states/user_state.dart';
import '../../domain/states/user_status_state.dart';
import '../screens/metrimony_flow_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/states/metrimony_state.dart';
import '../../domain/states/identity_state.dart';
import '../../domain/states/address_state.dart';
import '../../domain/states/education_state.dart';
import '../../domain/states/employee_state.dart';
import '../../domain/states/family_state.dart';
import '../../domain/states/cultural_state.dart';
import '../../domain/states/lifestyle_state.dart';
import '../../domain/states/physical_state.dart';

final metrimonyControllerProvider =
    StateNotifierProvider<MetrimonyController, MetrimonyState>(
      (ref) => MetrimonyController(),
    );

class MetrimonyController extends StateNotifier<MetrimonyState> {
  MetrimonyController() : super(MetrimonyState.initial());

  // ---------------- STEP NAVIGATION ----------------
  void nextStep() {
    final index = MatrimonyStep.values.indexOf(state.step);

    // ✅ LAST STEP COMPLETED
    if (index == MatrimonyStep.values.length - 1) {
      state = state.copyWith(isCompleted: true);
      return;
    }

    // ✅ MOVE TO NEXT STEP
    state = state.copyWith(step: MatrimonyStep.values[index + 1]);
  }

  void previousStep() {
    final index = MatrimonyStep.values.indexOf(state.step);
    if (index > 0) {
      state = state.copyWith(step: MatrimonyStep.values[index - 1]);
    }
  }

  // ---------------- SAVE METHODS ----------------
  void saveUser(AppUser data) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(user: data));
    nextStep();
  }

  void saveIdentity(IdentityProfile data) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(identity: data));
    nextStep();
  }

  void saveAddress(AddressProfile data) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(address: data));
    nextStep();
  }

  void saveEducation(EducationProfile data) {
    state = state.copyWith(
      metrimony: state.metrimony.copyWith(education: data),
    );
    nextStep();
  }

  void saveEmployment(EmploymentProfile data) {
    state = state.copyWith(
      metrimony: state.metrimony.copyWith(employment: data),
    );
    nextStep();
  }

  void saveFamily(FamilyProfile data) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(family: data));
    nextStep();
  }

  void saveCultural(CulturalProfile data) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(cultural: data));
    nextStep();
  }

  void saveLifestyle(LifestyleProfile data) {
    state = state.copyWith(
      metrimony: state.metrimony.copyWith(lifestyle: data),
    );
    nextStep();
  }

  void savePhysical(PhysicalProfile data) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(physical: data));
    nextStep();
  }

  // ---------------- SUBMIT METHODS ----------------
  Future<void> submitProfile(WidgetRef ref, String uid) async {
    // fetch current user data  from firestore
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    AppUser user = AppUser.fromMap(userData.data()!);

    // fetch agent id using agent_id field using agentfirestore ds

    AgentProfile agentData = await AgentFirestoreDs(
      FirebaseFirestore.instance,
    ).fetchAgentbyAgentId(user.agentId!);

    var profile = ref.read(metrimonyControllerProvider).metrimony;

    profile = profile.copyWith(user: user, agent: agentData);

    await ref
        .read(matrimonyRepositoryProvider)
        .updateMatrimonyProfile(uid, profile);
    await ref.read(userStatusRepositoryProvider).markProfileCreated(uid);
  }

  void saveImages(ProfileImages profileImages) {
    state = state.copyWith(
      metrimony: state.metrimony.copyWith(images: profileImages),
    );
    nextStep();
  }

  Future<void> createEmptyMatrimonyProfile(String uid, String agentId) async {
    debugPrint("Creating empty metrimony profile for $uid");
    // fetch current user data  from firestore
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    AppUser user = AppUser.fromMap(userData.data()!);

    // fetch agent id using agent_id field using agentfirestore ds

    AgentProfile agentData = await AgentFirestoreDs(
      FirebaseFirestore.instance,
    ).fetchAgentbyAgentId(agentId);

    // create empty metrimony profile

    final matrimonyRepository = MatrimonyRepositoryImpl(
      MatrimonyFirestoreDS(FirebaseFirestore.instance),
    );
    final userStatusRepository = UserStatusRepositoryImpl(
      UserStatusFirestoreDS(),
    );

    debugPrint("this is user data ");
    debugPrint(user.toString());
    debugPrint("this is agent data ");
    debugPrint(agentData.toString());

    final metrimonyProfile = MatrimonyProfile(
      user: user,

      agent: agentData,
      identity: IdentityProfile.empty(),
      address: AddressProfile.empty(),
      cultural: CulturalProfile.empty(),
      education: EducationProfile.empty(),
      employment: EmploymentProfile.empty(),
      family: FamilyProfile.empty(),
      lifestyle: LifestyleProfile.empty(),
      physical: PhysicalProfile.empty(),
      images: ProfileImages.empty(),
    );
    debugPrint(metrimonyProfile.toString());

    await matrimonyRepository.createMatrimonyProfile(
      uid,
      metrimonyProfile.toMap(),
    );
    await userStatusRepository.createUserStatus(uid);
  }

   
}
