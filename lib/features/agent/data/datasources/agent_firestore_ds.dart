// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../domain/states/agent_entity.dart';

// class AgentFirestoreDs {
//   final FirebaseFirestore firestore;
//   AgentFirestoreDs(this.firestore);

//   Future<AgentProfile> fetchProfile(String uid) async {
//     final doc = await firestore.collection('agents').doc(uid).get();
//     final data = doc.data();
//     if (data == null) throw Exception('agent not found');
//     return AgentProfile.fromMap(data..['uid'] = uid);
//   }

//   Stream<AgentProfile> watchProfile(String uid) =>
//       firestore.collection('agents').doc(uid).snapshots().map((s) {
//         final data = s.data();
//         if (data == null) throw Exception('agent not found');
//         return AgentProfile.fromMap(data..['uid'] = uid);
//       });

//   Future<void> updateProfile(String uid, Map<String, dynamic> updates) =>
//       firestore.collection('agents').doc(uid).update(updates);
// }
