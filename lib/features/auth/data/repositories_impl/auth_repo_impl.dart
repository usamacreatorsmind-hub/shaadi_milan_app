import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/states/agent_state.dart';
import '../../domain/states/user_state.dart';
import 'data_source/firebase_auth_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDS ds;
  final FirebaseFirestore firestore;
  AuthRepositoryImpl(this.ds, this.firestore);

  Future<QuerySnapshot<Map<String, dynamic>>?> _safeQuery(Query<Map<String, dynamic>> query) async {
    try {
      return await query.get().timeout(const Duration(seconds: 5));
    } catch (e) {
      return null;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _safeGetDoc(DocumentReference<Map<String, dynamic>> docRef) async {
    try {
      return await docRef.get().timeout(const Duration(seconds: 5));
    } catch (e) {
      return null;
    }
  }

  @override
  User? get currentUser => ds.currentUser;

  @override
  Future<dynamic> checkPhoneAlreadyRegistered(String phone) async {
    final usersQuery = await firestore.collection('users').where('phone', isEqualTo: phone).get();
    if (usersQuery.docs.isNotEmpty) {
      return true;
    }

    final agentsQuery = await firestore.collection('agents').where('phone', isEqualTo: phone).get();
    if (agentsQuery.docs.isNotEmpty) {
      return true;
    }

    return false;
  }

  @override
  Future<bool> checkUserExists({required String phone, required String email}) {
    return ds.checkUserIfExists(phone: phone, email: email);
  }

  Future<bool> _checkMatrimonyProfileCreatedInFirestore(String uid, String phone, String email) async {
    try {
      // 1. Direct doc check by UID
      final docByUid = await firestore.collection('metrimony_profiles').doc(uid).get().timeout(const Duration(seconds: 5));
      if (docByUid.exists) {
        return true;
      }

      // 2. Query by userId
      final queryByUserId = await firestore
          .collection('metrimony_profiles')
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      if (queryByUserId.docs.isNotEmpty) {
        return true;
      }

      // 3. Query by Phone
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      final last10 = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;
      if (last10.isNotEmpty) {
        var queryByPhone = await firestore
            .collection('metrimony_profiles')
            .where('phone', isEqualTo: last10)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 5));
        if (queryByPhone.docs.isEmpty) {
          queryByPhone = await firestore
              .collection('metrimony_profiles')
              .where('phone', isEqualTo: phone)
              .limit(1)
              .get()
              .timeout(const Duration(seconds: 5));
        }
        if (queryByPhone.docs.isNotEmpty) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking matrimony profile existence in authStateChanges: $e');
    }
    return false;
  }

  @override
  Stream<Either<AgentEntity, UserEntity>?> authStateChanges() => ds.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    final userPhone = user.phoneNumber ?? '';
    final userEmail = user.email ?? '';
    final cleanPhone = userPhone.replaceAll(RegExp(r'\D'), '');

    final bool isTestUser = cleanPhone.endsWith('9988998899') ||
        cleanPhone.endsWith('8877887788') ||
        userEmail.contains('test_male_9988998899') ||
        userEmail.contains('test_female_8877887788');

    // Pre-check if matrimony profile exists for user.uid
    bool profileExistsForUid = await _checkMatrimonyProfileCreatedInFirestore(user.uid, userPhone, userEmail);

    try {
      // 1. Try fetching user document by UID with retries for transient auth/network propagation delays
      DocumentSnapshot<Map<String, dynamic>>? userDoc;
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          userDoc = await firestore.collection('users').doc(user.uid).get().timeout(const Duration(seconds: 5));
          if (userDoc.exists) break;
        } catch (e) {
          debugPrint('Error fetching user doc by UID (attempt $attempt): $e');
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      if (userDoc != null && userDoc.exists && userDoc.data() != null) {
        final data = Map<String, dynamic>.from(userDoc.data()!);
        if (isTestUser || profileExistsForUid) {
          data['isProfileCreated'] = true;
          data['userStatus'] = {'isProfileCreated': true};
        } else {
          bool isProfileCreated = UserEntity.fromMap(data).isProfileCreated;
          if (!isProfileCreated) {
            final phoneNum = (data['phone'] ?? userPhone).toString();
            final emailAddr = (data['email'] ?? userEmail).toString();
            final profileExists = await _checkMatrimonyProfileCreatedInFirestore(user.uid, phoneNum, emailAddr);
            if (profileExists) {
              data['isProfileCreated'] = true;
              data['userStatus'] = {'isProfileCreated': true};
              // Self-heal users doc in background
              firestore.collection('users').doc(user.uid).set({
                'isProfileCreated': true,
                'userStatus': {'isProfileCreated': true},
              }, SetOptions(merge: true));
            }
          }
        }
        return Right(UserEntity.fromMap(data));
      }

      // 2. Try fetching agent document by UID
      DocumentSnapshot<Map<String, dynamic>>? agentDoc;
      try {
        agentDoc = await firestore.collection('agents').doc(user.uid).get().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Error fetching agent doc by UID: $e');
      }

      if (agentDoc != null && agentDoc.exists && agentDoc.data() != null) {
        return Left(AgentEntity.fromMap(agentDoc.data()!));
      }

      // 3. Fallback search by Phone or Email if doc by user.uid doesn't exist
      QueryDocumentSnapshot<Map<String, dynamic>>? matchedDoc;

      if (cleanPhone.isNotEmpty || isTestUser) {
        final searchPhone = isTestUser ? (cleanPhone.endsWith('8877887788') ? '8877887788' : '9988998899') : cleanPhone;
        final last10 = searchPhone.length >= 10 ? searchPhone.substring(searchPhone.length - 10) : searchPhone;

        var phoneQuery = await _safeQuery(firestore.collection('users').where('phone', isEqualTo: userPhone).limit(1));
        if (phoneQuery == null || phoneQuery.docs.isEmpty) {
          phoneQuery = await _safeQuery(firestore.collection('users').where('phone', isEqualTo: last10).limit(1));
        }
        if (phoneQuery == null || phoneQuery.docs.isEmpty) {
          phoneQuery = await _safeQuery(firestore.collection('users').where('phone', isEqualTo: '+91$last10').limit(1));
        }
        if (phoneQuery != null && phoneQuery.docs.isNotEmpty) {
          matchedDoc = phoneQuery.docs.first;
        }
      }

      if (matchedDoc == null && (userEmail.isNotEmpty || isTestUser)) {
        final searchEmail = userEmail.isNotEmpty
            ? userEmail
            : (cleanPhone.endsWith('8877887788') ? 'test_female_8877887788@shaadimilan.com' : 'test_male_9988998899@shaadimilan.com');
        final emailQuery = await _safeQuery(firestore.collection('users').where('email', isEqualTo: searchEmail).limit(1));
        if (emailQuery != null && emailQuery.docs.isNotEmpty) {
          matchedDoc = emailQuery.docs.first;
        }
      }

      if (matchedDoc != null) {
        final matchedData = Map<String, dynamic>.from(matchedDoc.data());
        matchedData['uid'] = user.uid; // bind current auth uid
        if (isTestUser || profileExistsForUid) {
          matchedData['isProfileCreated'] = true;
          matchedData['userStatus'] = {'isProfileCreated': true};
        } else {
          bool isProfileCreated = UserEntity.fromMap(matchedData).isProfileCreated;
          if (!isProfileCreated) {
            final phoneNum = (matchedData['phone'] ?? userPhone).toString();
            final emailAddr = (matchedData['email'] ?? userEmail).toString();
            final profileExists = await _checkMatrimonyProfileCreatedInFirestore(user.uid, phoneNum, emailAddr) ||
                await _checkMatrimonyProfileCreatedInFirestore(matchedDoc.id, phoneNum, emailAddr);
            if (profileExists) {
              matchedData['isProfileCreated'] = true;
              matchedData['userStatus'] = {'isProfileCreated': true};
            }
          }
        }
        await firestore.collection('users').doc(user.uid).set(matchedData, SetOptions(merge: true));
        return Right(UserEntity.fromMap(matchedData));
      }

      // 4. Recover user details from metrimony_profiles if available for user.uid
      DocumentSnapshot<Map<String, dynamic>>? matDoc;
      try {
        matDoc = await firestore.collection('metrimony_profiles').doc(user.uid).get().timeout(const Duration(seconds: 5));
      } catch (_) {}

      if (matDoc != null && matDoc.exists && matDoc.data() != null) {
        final mData = matDoc.data()!;
        final recoveredData = <String, dynamic>{
          'uid': user.uid,
          'phone': mData['phone'] ?? userPhone,
          'email': mData['email'] ?? userEmail,
          'fullName': mData['fullName'] ?? mData['identity']?['fullName'] ?? {'en': user.displayName ?? '', 'hi': ''},
          'gender': mData['gender'] ?? mData['identity']?['gender'] ?? {'en': '', 'hi': ''},
          'role': 'user',
          'profileStatus': 'active',
          'isProfileCreated': true,
          'userStatus': {'isProfileCreated': true},
        };

        await firestore.collection('users').doc(user.uid).set(recoveredData, SetOptions(merge: true));
        return Right(UserEntity.fromMap(recoveredData));
      }

      // 5. If test user and still no document found in Firestore, create/seed default test profile immediately!
      if (isTestUser) {
        final isFemale = cleanPhone.endsWith('8877887788') || userEmail.contains('test_female');
        final defaultTestData = <String, dynamic>{
          'uid': user.uid,
          'phone': isFemale ? '8877887788' : '9988998899',
          'email': isFemale ? 'test_female_8877887788@shaadimilan.com' : 'test_male_9988998899@shaadimilan.com',
          'fullName': {'en': isFemale ? 'Test Female Reviewer' : 'Test Male Reviewer', 'hi': isFemale ? 'टेस्ट फीमेल' : 'टेस्ट मेल'},
          'gender': {'en': isFemale ? 'Female' : 'Male', 'hi': isFemale ? 'महिला' : 'पुरुष'},
          'role': 'user',
          'profileStatus': 'active',
          'isProfileCreated': true,
          'userStatus': {'isProfileCreated': true},
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        };

        try {
          await firestore.collection('users').doc(user.uid).set(defaultTestData, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Error seeding test user profile doc: $e');
        }

        return Right(UserEntity.fromMap(defaultTestData));
      }
    } catch (e) {
      debugPrint('Error in authStateChanges asyncMap: $e');
    }

    // Authenticated but no Firestore record yet -> Ensure user document exists under user.uid
    final fallbackData = <String, dynamic>{
      'uid': user.uid,
      'phone': user.phoneNumber ?? '',
      'email': user.email ?? '',
      'fullName': {'en': user.displayName ?? '', 'hi': ''},
      'gender': {'en': '', 'hi': ''},
      'role': 'user',
      'profileStatus': 'active',
      'isProfileCreated': profileExistsForUid || isTestUser,
      'userStatus': {'isProfileCreated': profileExistsForUid || isTestUser},
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    };

    try {
      await firestore.collection('users').doc(user.uid).set(fallbackData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating fallback user record: $e');
    }

    return Right(UserEntity.fromMap(fallbackData));
  });

  @override
  Future<void> signOut() async {
    await ds.signOut();
  }

  // @override
  // Future<bool> checkUserIfExists({String? uid}) async {
  //   final targetUid = uid ?? currentUser?.uid;
  //   if (targetUid == null) return false;
  //   return await ds.checkUserIfExists(uid: targetUid);
  // }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return ds.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signInAgentWithEmail(String email, String password) {
    return ds.signInAgentWithEmail(email, password);
  }

  @override
  Future<void> signInUserWithEmail(String email, String password) {
    return ds.signInUserWithEmail(email, password);
  }

  @override
  Future<UserCredential> signInWithEmail(String email, String password) {
    return ds.signInUserWithEmail(email, password);
  }

  @override
  Future<void> signUpUserWithEmail({
    required BilingualValue fullName,
    required BilingualValue gender,

    required String email,
    required String password,
    required String agentId,
    required String phone,
  }) async {
    // show aget page

    // 3️⃣ create user (THIS WAS MISSING)
    await ds.signUpUserWithEmail(gender: gender, fullName: fullName, email: email, password: password, agentId: agentId, phone: phone);
  }

  @override
  Future<void> logout() {
    return ds.logout();
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) {
    return ds.verifyPhoneNumber(phoneNumber: phoneNumber, onCodeSent: onCodeSent, onVerificationFailed: onVerificationFailed);
  }

  @override
  Future<UserCredential> signInWithPhoneCredential(String verificationId, String smsCode) {
    return ds.signInWithPhoneCredential(verificationId, smsCode);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return ds.updatePassword(newPassword);
  }

  @override
  Future<Map<String, dynamic>> sendMSG91OTP(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // 🧪 Play Console Reviewer Bypass for Test Numbers: Male (9988998899) & Female (8877887788)
    if (cleanPhone.endsWith('9988998899') || cleanPhone.endsWith('8877887788')) {
      return {'success': true, 'message': 'OTP sent successfully (Test Bypass)'};
    }

    try {
      final result = await FirebaseFunctions.instance.httpsCallable('sendMSG91OTP').call({'phoneNumber': phone});
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> verifyMSG91OTP(String phone, String otp) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // 🧪 Play Console Reviewer Bypass for Male (9988998899 -> 1234) & Female (8877887788 -> 4567)
    final bool isMaleBypass = cleanPhone.endsWith('9988998899');
    final bool isFemaleBypass = cleanPhone.endsWith('8877887788');

    if (isMaleBypass || isFemaleBypass) {
      final String expectedOtp = isMaleBypass ? '1234' : '4567';

      if (otp == expectedOtp) {
        try {
          // 1. Try Cloud Functions first
          final result = await FirebaseFunctions.instance.httpsCallable('verifyMSG91OTP').call({'phoneNumber': phone, 'otp': expectedOtp});
          final data = Map<String, dynamic>.from(result.data as Map);
          if (data['success'] == true && data['verified'] == true && data['registered'] == true) {
            final customToken = data['customToken'] as String;
            await FirebaseAuth.instance.signInWithCustomToken(customToken);

            final currentUid = FirebaseAuth.instance.currentUser?.uid;
            if (currentUid != null) {
              await firestore.collection('users').doc(currentUid).set({
                'uid': currentUid,
                'phone': isMaleBypass ? '9988998899' : '8877887788',
                'email': isMaleBypass ? 'test_male_9988998899@shaadimilan.com' : 'test_female_8877887788@shaadimilan.com',
                'isProfileCreated': true,
                'userStatus': {'isProfileCreated': true},
              }, SetOptions(merge: true));
            }

            return data;
          }
        } catch (e) {
          debugPrint('Cloud function verifyMSG91OTP failed: $e');
        }

        // 2. Client-side fallback: Find user in Firestore by phone or seed test user
        try {
          final usersQuery = await firestore.collection('users').where('phone', isEqualTo: phone).limit(1).get();
          var userDoc = usersQuery.docs.isNotEmpty ? usersQuery.docs.first : null;

          if (userDoc == null) {
            final queryAll = await firestore.collection('users').get();
            for (final doc in queryAll.docs) {
              final p = doc.data()['phone']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
              if (p.endsWith(cleanPhone)) {
                userDoc = doc;
                break;
              }
            }
          }

          final userData = userDoc != null ? Map<String, dynamic>.from(userDoc.data()) : <String, dynamic>{};
          final email =
              (userData['email']?.toString().isNotEmpty == true)
                  ? userData['email'].toString()
                  : (isMaleBypass ? 'test_male_9988998899@shaadimilan.com' : 'test_female_8877887788@shaadimilan.com');
          const password = 'TestPassword123!';

          UserCredential? cred;
          try {
            cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          } catch (_) {
            try {
              cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
            } catch (_) {}
          }

          final signedInUid = cred?.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
          if (signedInUid != null) {
            userData['uid'] = signedInUid;
            userData['phone'] = isMaleBypass ? '9988998899' : '8877887788';
            userData['email'] = email;
            userData['isProfileCreated'] = true;
            userData['userStatus'] = {'isProfileCreated': true};

            if (!userData.containsKey('fullName')) {
              userData['fullName'] = {'en': isMaleBypass ? 'Test Male Reviewer' : 'Test Female Reviewer', 'hi': isMaleBypass ? 'टेस्ट मेल' : 'टेस्ट फीमेल'};
            }
            if (!userData.containsKey('gender')) {
              userData['gender'] = {'en': isMaleBypass ? 'Male' : 'Female', 'hi': isMaleBypass ? 'पुरुष' : 'महिला'};
            }
            userData['role'] = 'user';
            userData['profileStatus'] = 'active';

            // Ensure user document exists under current signedInUid with all profile data
            await firestore.collection('users').doc(signedInUid).set(userData, SetOptions(merge: true));
          }

          return {'success': true, 'verified': true, 'registered': true, 'message': 'Login successful'};
        } catch (e) {
          debugPrint('Fallback test login error: $e');
        }

        return {'success': true, 'verified': true, 'registered': true, 'message': 'Login successful'};
      } else {
        return {
          'success': false,
          'verified': false,
          'registered': true,
          'message': 'Invalid OTP. Please enter $expectedOtp for test number.',
        };
      }
    }

    try {
      final result = await FirebaseFunctions.instance.httpsCallable('verifyMSG91OTP').call({'phoneNumber': phone, 'otp': otp});

      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['success'] == true && data['verified'] == true && data['registered'] == true) {
        final customToken = data['customToken'] as String;
        await FirebaseAuth.instance.signInWithCustomToken(customToken);

        final signedInUid = FirebaseAuth.instance.currentUser?.uid;
        if (signedInUid != null && signedInUid.isNotEmpty) {
          final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
          final last10 = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

          // Prime & heal user document in Firestore right after custom token login
          final userDocRef = firestore.collection('users').doc(signedInUid);
          final userDoc = await _safeGetDoc(userDocRef);

          bool profileCreated = false;
          final matDoc = await _safeGetDoc(firestore.collection('metrimony_profiles').doc(signedInUid));
          if (matDoc != null && matDoc.exists) {
            profileCreated = true;
          } else {
            final matQuery = await _safeQuery(firestore.collection('metrimony_profiles').where('userId', isEqualTo: signedInUid).limit(1));
            if (matQuery != null && matQuery.docs.isNotEmpty) {
              profileCreated = true;
            }
          }

          if (userDoc != null && userDoc.exists && userDoc.data() != null) {
            final existingData = Map<String, dynamic>.from(userDoc.data()!);
            if (profileCreated || existingData['isProfileCreated'] == true) {
              existingData['isProfileCreated'] = true;
              existingData['userStatus'] = {'isProfileCreated': true};
              await userDocRef.set(existingData, SetOptions(merge: true));
            }
          } else {
            // Document under signedInUid not found; search if existing user document exists by phone
            var phoneQuery = await _safeQuery(firestore.collection('users').where('phone', isEqualTo: phone).limit(1));
            if (phoneQuery == null || phoneQuery.docs.isEmpty) {
              phoneQuery = await _safeQuery(firestore.collection('users').where('phone', isEqualTo: last10).limit(1));
            }
            if (phoneQuery == null || phoneQuery.docs.isEmpty) {
              phoneQuery = await _safeQuery(firestore.collection('users').where('phone', isEqualTo: '+91$last10').limit(1));
            }

            Map<String, dynamic> initialData = {};
            if (phoneQuery != null && phoneQuery.docs.isNotEmpty) {
              initialData = Map<String, dynamic>.from(phoneQuery.docs.first.data());
            }

            initialData['uid'] = signedInUid;
            if ((initialData['phone'] ?? '').toString().isEmpty) {
              initialData['phone'] = last10;
            }
            if (profileCreated) {
              initialData['isProfileCreated'] = true;
              initialData['userStatus'] = {'isProfileCreated': true};
            }
            await userDocRef.set(initialData, SetOptions(merge: true));
          }
        }
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
