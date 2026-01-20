import '../../../../auth/domain/states/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

abstract class UserFirestore {
  Future<List<UserEntity>> getUsersForAgent(String agentId);
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
}

class UserFirestoreImpl implements UserFirestore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<List<UserEntity>> getUsersForAgent(String agentId) async {
    //fetch user from firestore where agentId matches
    debugPrint("getting Users for Agent");
    List<UserEntity> users = await firestore
        .collection('users')
        .where('agentId', isEqualTo: agentId)
        .get()
        .then((querySnapshot) {
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

    throw UnimplementedError();
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
