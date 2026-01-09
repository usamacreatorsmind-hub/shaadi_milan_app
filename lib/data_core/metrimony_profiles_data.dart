// import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/user_firestore_ds.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/address_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/agent_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/cultural_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/education_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/employee_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/family_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/identity_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/image_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/lifestyle_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/physical_state.dart';
// import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/user_state.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<UserEntity> fetchUserProfile(String userId) async {
//   final userFirestoreDs = UserFirestoreDS(FirebaseFirestore.instance);
//   final userData = await userFirestoreDs.fetchUser(userId);
//   return UserEntity.fromMap(userData);
// }

// Future<AgentEntity> fetchAgentEntity(String agentId) async {
//   final agentFirestoreDs = AgentFirestoreDs(FirebaseFirestore.instance);
//   return await agentFirestoreDs.fetchAgentbyAgentId(agentId);
// }

// final uid = "cTfOSye3OO6sdPa48zgBy1pucm2";
// final UserEntity dummyUser = UserEntity(
//   uid: uid, // 🔥 REAL UID
//   fullName: '',
//   email: '',
//   role: 'user',

// );
// final agentId = "81266";
// final AgentEntity dummyAgent = AgentEntity(
//   agentId: agentId,
//   agentName: '',
//   agentMobile: '',
//   registrationDate: DateTime.now(),
//   role: '',
//   agentAadhar: '',
//   uid: '',
//   email: '',
// );

// List<MatrimonyProfile> metrimonyProfiles = [
//   MatrimonyProfile(
//     identity: IdentityProfile(
//       profileId: 'MP001',
//       gender: 'Male',
//       dob: DateTime(1990, 5, 15),
//       age: 33,
//       aadhar: '1234-5678-9012',
//     ),
//     lifestyle: LifestyleProfile(
//       diet: 'Vegetarian',
//       hobbies: ['Reading', 'Hiking'],
//       interests: ['Technology', 'Travel'],
//       music: ['Classical', 'Rock'],
//       movies: ['Sci-Fi', 'Drama'],
//       sports: ['Cricket', 'Badminton'],
//       fitness: 'Active',
//     ),
//     cultural: CulturalProfile(
//       religion: 'Hindu',
//       caste: 'Brahmin',
//       subCaste: 'Saraswat',
//       gothra: 'Bharadwaj',
//       motherTongue: 'Hindi',
//       languages: ['Hindi', 'English', 'Sanskrit'],
//     ),
//     address: AddressProfile(
//       addressLine1: '123, Main Street',
//       post: 'GPO',
//       policeStation: 'Civil Lines',
//       city: 'New Delhi',
//       state: 'Delhi',
//       pincode: '110001',
//     ),
//     agent: dummyAgent,
//     education: EducationProfile(
//       graduation: Graduation(
//         college: 'IIT Delhi',
//         degree: 'B.Tech',
//         passingYear: 2012,
//         percentage: 85.5,
//       ),
//       intremidiate: IntremidiateProfile(
//         collegeName: 'FIITJEE Junior College',
//         board: 'CBSE',
//         percentage: 92.0,
//         passingYear: 2008,
//       ),
//       metriculation: Metriculation(
//         schoolName: 'DPS',
//         board: 'CBSE',
//         percentage: 90.0,
//         passingYear: 2006,
//       ),
//     ),
//     employment: EmploymentProfile(
//       jobType: 'Software Engineer',
//       company: 'Google',
//       designation: 'Software Engineer',
//       annualIncome: 1000000,
//       workLocation: 'Bangalore',
//     ),
//     family: FamilyProfile(
//       fatherName: 'Ram Singh',
//       motherName: 'Sita Devi',
//       numberOfBrothers: 1,
//       numberOfSisters: 1,
//       familyType: 'Nuclear',
//       familyStatus: 'Middle Class',
//     ),
//     images: ProfileImages(
//       primaryImageUrl:
//           'https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png',
//       secondaryImageUrls: [],
//     ),
//     physical: PhysicalProfile(
//       height: "170",
//       weight: 70,
//       bodyType: 'Athletic',
//       complexion: 'Fair',
//       physicallyChallenged: false,
//     ),
//     user: dummyUser,
//   ),
// ];

// Future<void> addMatrimonyProfilesToFirestore() async {
//   final firestore = FirebaseFirestore.instance;
//   final collection = firestore.collection('matrimony_profiles');

//   try {
//     for (final profile in metrimonyProfiles) {
//       final fetchedUser = await fetchUserProfile(profile.user!.uid);
//       final fetchedAgent = await fetchAgentEntity(profile.agent!.agentId);

//       final updatedProfile = profile.copyWith(
//         user: fetchedUser,
//         agent: fetchedAgent,
//       );

//       await collection.add(updatedProfile.toMap());
//       print("✅ Profile added successfully");
//     }
//   } catch (e, stack) {
//     print("❌ Error adding profile: $e");
//     print(stack);
//   }
// }
