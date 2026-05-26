import '../../../../auth/domain/states/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

abstract class UserFirestore {
  Future<List<UserEntity>> getUsersForAgent();
  Future<UserEntity> getUserById(String userId);

  Future<void> updateUserStatus({
    required String userId,
    required String status,
    String? reason,
  });
  Future<void> updateUserWishlist({
    required String userId,
    required List<Map<String, dynamic>> wishlists,
  });

  Future<void> closeMatrimonyProfile(String userId) async {}
}

class UserFirestoreImpl implements UserFirestore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> closeMatrimonyProfile(String userId) async {
    print("Closing  metrimony profile");
    final userRef = firestore.collection('users').doc(userId);
    final matrimonyRef = firestore.collection('metrimony_profiles').doc(userId);

    await firestore.runTransaction((transaction) async {
      final matrimonySnap = await transaction.get(matrimonyRef);
      print("inside transaction");
      if (!matrimonySnap.exists) {
        throw Exception('Matrimony profile not found');
      }

      transaction.update(matrimonyRef, {
        'profileStatus': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': 'agent',
      });

      transaction.update(userRef, {
        'profileStatus': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<List<UserEntity>> getUsersForAgent() async {
    //fetch user from firestore where agentId matches
    debugPrint("getting Users for Agent");
    List<UserEntity> users = await firestore.collection('users').get().then((
      querySnapshot,
    ) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Add document ID as uid
        return UserEntity.fromMap(data);
      }).toList();
    });
    for (var user in users) {
      debugPrint(user.toString());
    }
    return users;
  }

  @override
  Future<UserEntity> getUserById(String userId) {
    return firestore.collection('users').doc(userId).get().then((doc) {
      final data = doc.data();
      if (data == null) {
        throw Exception('user not found');
      }
      data['uid'] = doc.id; // Add document ID as uid
      return UserEntity.fromMap(data);
    });
  }

  @override
  Future<void> updateUserStatus({
    required String userId,
    required String status,
    String? reason,
  }) {
    return firestore.collection('users').doc(userId).update({
      'userStatus': {
        'status': status,
        'reason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  @override
  Future<void> updateUserWishlist({
    required String userId,
    required List<Map<String, dynamic>> wishlists,
  }) {
    return firestore.collection('users').doc(userId).update({
      'wishlists': wishlists,
    });
  }
}
