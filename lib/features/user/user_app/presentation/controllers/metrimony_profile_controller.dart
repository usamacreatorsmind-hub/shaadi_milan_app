import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/user/user_razorpay/data/firestore/payment_firestore.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';

import '../../data/datasources/firebase/agent_firestore_ds.dart';
import '../../data/repositories_impl/matrimony_repository_impl.dart';
import '../../domain/states/address_state.dart';
import '../../domain/states/cultural_state.dart';
import '../../domain/states/education_state.dart';
import '../../domain/states/employee_state.dart';
import '../../domain/states/family_state.dart';
import '../../domain/states/identity_state.dart';
import '../../domain/states/image_state.dart';
import '../../domain/states/metrimony_state.dart';
import '../../domain/states/physical_state.dart';
import '../screens/metrimony_flow_screen.dart';

final metrimonyControllerProvider =
    StateNotifierProvider<MetrimonyController, MetrimonyState>(
      (ref) => MetrimonyController(ref),
    );

class MetrimonyController extends StateNotifier<MetrimonyState> {
  final Ref ref;

  MetrimonyController(this.ref) : super(MetrimonyState.initial());

  // ================= STEP NAVIGATION =================

  void nextStep() {
    final currentIndex = MatrimonyStep.values.indexOf(state.step);
    if (currentIndex < MatrimonyStep.values.length - 1) {
      state = state.copyWith(step: MatrimonyStep.values[currentIndex + 1]);
    }
  }

  void previousStep() {
    final currentIndex = MatrimonyStep.values.indexOf(state.step);
    if (currentIndex > 0) {
      state = state.copyWith(step: MatrimonyStep.values[currentIndex - 1]);
    }
  }

  // ================= SAVE STEP DATA =================

  void saveUser(String userId) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(userId: userId));
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

  void savePhysical(PhysicalProfile data) {
    state = state.copyWith(metrimony: state.metrimony.copyWith(physical: data));
    nextStep();
  }

  void saveImages(ProfileImages profileImages) {
    state = state.copyWith(
      metrimony: state.metrimony.copyWith(images: profileImages),
    );
    nextStep();
  }

  // ================= CREATE EMPTY PROFILE =================
  // 🔥 UID IS USED AS DOCUMENT ID (IMPORTANT)

  Future<void> createEmptyMatrimonyProfile(String uid, String agentId) async {
    String agentUid = '';

    if (agentId.isNotEmpty) {
      final agentDS = ref.read(agentFirestoreDsProvider);
      agentUid = await agentDS.fetchAgentDocIdByAgentId(agentId: agentId) ?? '';

      debugPrint('Fetched Agent UID at createEmptyMatrimonyProfile: $agentUid');
    }

    // fetch full name of user
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final userData = userDoc.data();
    final fullNameMap = userData?['fullName'];
    String fullName = '';
    if (fullNameMap is Map) {
      fullName = fullNameMap['en'] ?? '';
    } else {
      fullName = fullNameMap?.toString() ?? '';
    }

    debugPrint('Fetched User Full Name: $fullName');

    final metrimonyProfile = MatrimonyProfile(
      userId: uid,
      metrimonyId: uid,
      profileStatus: 'active',

      // ✅ SAME AS UID
      identity: IdentityProfile.empty(),
      address: AddressProfile.empty(),
      cultural: CulturalProfile.empty(),
      education: EducationProfile.empty(),
      employment: EmploymentProfile.empty(),
      family: FamilyProfile.empty(),
      physical: PhysicalProfile.empty(),
      images: ProfileImages.empty(),
    );

    await FirebaseFirestore.instance
        .collection('metrimony_profiles')
        .doc(uid)
        .set(metrimonyProfile.toMap());

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isProfileCreated': false,
      'userStatus': {'isProfileCreated': false},
    });
  }

  // ================= SUBMIT PROFILE =================

  Future<void> submitProfile({
    required String uid,
    required String agentId,
  }) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final userData = userDoc.data();
    final fullNameMap = userData?['fullName'];
    String fullName = '';
    if (fullNameMap is Map) {
      fullName = fullNameMap['en'] ?? '';
    } else {
      fullName = fullNameMap?.toString() ?? '';
    }
    final email = userData?['email'] ?? '';
    final phone = userData?['phone'] ?? '';

    debugPrint('Fetched User Full Name: $fullName');

    var profile = state.metrimony.copyWith(userId: uid, metrimonyId: uid);

    debugPrint('Profile submitted: ${profile.toMap()}');

    PaymentFirestore().createEmptyPayment(
      initialPaymentData: Payment(
        razorpayPaymentId: '',
        paymentType: '',
        agentId: agentId,
        region: profile.address.state.en,
        district: profile.address.city.en,
        gender: profile.identity.gender.en,
        religion: profile.cultural.religion.en,
        caste: profile.cultural.caste.en,
        orderId: '',
        razorpayOrderId: '',
        userId: uid,
        email: email,
        phone: phone,
        fullName: fullName,
        amount: 0,
        status: 'IDLE',
        createdAt: DateTime.now(),
      ),
      uid: uid,
    );

    await ref
        .read(matrimonyRepositoryProvider)
        .updateMatrimonyProfile(uid, profile);
    // Update profileImageUrl in users collection with profileImageUrl
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImageUrl': profile.images.profileImageUrl,
      'isProfileCreated': true,
      'userStatus': {'isProfileCreated': true},
    });
  }
}
