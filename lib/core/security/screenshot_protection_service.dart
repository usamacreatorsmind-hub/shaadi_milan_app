import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenshot_blocker/flutter_screenshot_blocker.dart';

import '../../features/auth/domain/states/agent_state.dart';
import '../../features/auth/domain/states/user_state.dart';

/// Controls screenshot & screen-recording protection dynamically based on
/// the currently authenticated account.
///
/// Only the whitelisted male/female test accounts are permitted to capture
/// screenshots or record the screen. All other users, agents, and
/// unauthenticated sessions have capture protection enabled.
class ScreenshotProtectionService {
  ScreenshotProtectionService._();

  static final ScreenshotProtectionService instance =
      ScreenshotProtectionService._();

  /// Whitelisted 10-digit mobile numbers allowed to take screenshots/recordings.
  static const Set<String> _allowedPhones10 = {
    '9988998899', // Male test account (OTP: 1234)
    '8877887788', // Female test account (OTP: 4567)
  };

  /// Whitelisted email addresses (lowercase) allowed to take screenshots/recordings.
  static const Set<String> _allowedEmails = {
    'karthik12@gmail.com', // Male email login
    'sweety234@gmail.com', // Female email login
    'test_male_9988998899@shaadimilan.com', // Male OTP fallback email
    'test_female_8877887788@shaadimilan.com', // Female OTP fallback email
  };

  bool? _desiredBlocked;
  bool? _appliedBlocked;
  bool _isApplying = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Returns `true` if the given [phone] or [email] belongs to a whitelisted
  /// account that is allowed to take screenshots and record the screen.
  static bool isAccountAllowedForCapture({String? phone, String? email}) {
    final normalizedEmail = (email ?? '').trim().toLowerCase();
    if (normalizedEmail.isNotEmpty &&
        _allowedEmails.contains(normalizedEmail)) {
      return true;
    }

    final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) {
      for (final allowed in _allowedPhones10) {
        if (digits == allowed ||
            digits == '91$allowed' ||
            digits == '0$allowed') {
          return true;
        }
      }
    }

    return false;
  }

  /// Determines whether screenshot & screen recording should be blocked for
  /// the given resolved auth entity (`Left(AgentEntity)`, `Right(UserEntity)`,
  /// or `null` when signed out), also checking [firebaseUser] metadata.
  static bool shouldBlockForSession({
    Either<AgentEntity, UserEntity>? authEntity,
    User? firebaseUser,
  }) {
    if (authEntity == null) {
      // Signed out (or no resolved profile): block by default.
      return true;
    }

    return authEntity.fold(
      // Agents are never whitelisted for screen capture.
      (_) => true,
      (user) {
        final allowedByEntity = isAccountAllowedForCapture(
          phone: user.phone,
          email: user.email,
        );
        if (allowedByEntity) return false;

        final allowedByFirebase = isAccountAllowedForCapture(
          phone: firebaseUser?.phoneNumber,
          email: firebaseUser?.email,
        );
        return !allowedByFirebase;
      },
    );
  }

  /// Syncs protection using the resolved auth entity from [authStateProvider].
  Future<void> syncWithAuthEntity(
    Either<AgentEntity, UserEntity>? authEntity, {
    bool force = false,
  }) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final shouldBlock = shouldBlockForSession(
      authEntity: authEntity,
      firebaseUser: firebaseUser,
    );
    await setBlocked(shouldBlock, force: force);
  }

  /// Syncs protection during app startup / auth loading using [FirebaseAuth.currentUser]
  /// if available; defaults to blocked otherwise.
  Future<void> syncWithCurrentFirebaseUser({bool force = false}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      await setBlocked(true, force: force);
      return;
    }

    final allowed = isAccountAllowedForCapture(
      phone: firebaseUser.phoneNumber,
      email: firebaseUser.email,
    );
    await setBlocked(!allowed, force: force);
  }

  /// Applies screenshot & screen-recording blocking state safely without race
  /// conditions between rapid auth or lifecycle updates.
  Future<void> setBlocked(bool shouldBlock, {bool force = false}) async {
    if (!_isSupportedPlatform) return;

    if (_desiredBlocked != shouldBlock) {
      _retryCount = 0;
    }
    _desiredBlocked = shouldBlock;
    if (!force && _appliedBlocked == shouldBlock && !_isApplying) {
      return;
    }

    if (_isApplying) return;
    _isApplying = true;
    bool pendingForce = force;

    try {
      while (_desiredBlocked != null) {
        final target = _desiredBlocked!;
        if (!pendingForce && _appliedBlocked == target) {
          break;
        }
        pendingForce = false;

        final ok = await _applyNative(target);
        if (ok) {
          _appliedBlocked = target;
          _retryCount = 0;
        } else {
          // On iOS cold start the key UIWindow may not be attached yet; retry briefly up to _maxRetries.
          if (_retryCount < _maxRetries) {
            _retryCount++;
            Future.delayed(const Duration(milliseconds: 350), () {
              if (_desiredBlocked == target && _appliedBlocked != target) {
                setBlocked(target, force: true);
              }
            });
          }
          break;
        }

        if (_desiredBlocked == target) {
          break;
        }
      }
    } finally {
      _isApplying = false;
    }
  }

  Future<bool> _applyNative(bool block) async {
    try {
      if (block) {
        return await FlutterScreenshotBlocker.enableScreenshotBlocking();
      } else {
        return await FlutterScreenshotBlocker.disableScreenshotBlocking();
      }
    } catch (e) {
      debugPrint('ScreenshotProtectionService error (block=$block): $e');
      return false;
    }
  }
}
