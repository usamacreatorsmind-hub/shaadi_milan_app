import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadi_milan/core/security/screenshot_protection_service.dart';
import 'package:shadi_milan/features/auth/domain/states/agent_state.dart';
import 'package:shadi_milan/features/auth/domain/states/user_state.dart';

void main() {
  group('ScreenshotProtectionService.isAccountAllowedForCapture', () {
    test('allows male test phone in common formats', () {
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '9988998899',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '+919988998899',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '919988998899',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '+91 99889-98899',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '09988998899',
        ),
        isTrue,
      );
    });

    test('allows female test phone in common formats', () {
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '8877887788',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '+918877887788',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '918877887788',
        ),
        isTrue,
      );
    });

    test('allows whitelisted male and female emails (case-insensitive)', () {
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          email: 'karthik12@gmail.com',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          email: '  KARTHIK12@GMAIL.COM  ',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          email: 'sweety234@gmail.com',
        ),
        isTrue,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          email: 'Sweety234@Gmail.com',
        ),
        isTrue,
      );
    });

    test('blocks all other phone numbers and emails', () {
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '9876543210',
          email: 'other@gmail.com',
        ),
        isFalse,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          email: 'karthik123@gmail.com',
        ),
        isFalse,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          email: 'sweety2345@gmail.com',
        ),
        isFalse,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '1239988998899',
        ),
        isFalse,
      );
      expect(
        ScreenshotProtectionService.isAccountAllowedForCapture(
          phone: '',
          email: '',
        ),
        isFalse,
      );
    });
  });

  group('ScreenshotProtectionService.shouldBlockForSession', () {
    test('blocks when signed out (authEntity is null)', () {
      expect(
        ScreenshotProtectionService.shouldBlockForSession(authEntity: null),
        isTrue,
      );
    });

    test('blocks for any agent session', () {
      final agent = AgentEntity.empty().copyWith(
        uid: 'agent1',
        agentEmail: 'agent@shaadimilan.com',
        agentMobile: '9876543210',
      );
      expect(
        ScreenshotProtectionService.shouldBlockForSession(
          authEntity: Left(agent),
        ),
        isTrue,
      );
    });

    test('allows for whitelisted male/female users', () {
      final malePhoneUser = UserEntity.empty().copyWith(phone: '9988998899');
      final femalePhoneUser = UserEntity.empty().copyWith(
        phone: '+918877887788',
      );
      final maleEmailUser = UserEntity.empty().copyWith(
        email: 'karthik12@gmail.com',
      );
      final femaleEmailUser = UserEntity.empty().copyWith(
        email: 'sweety234@gmail.com',
      );

      expect(
        ScreenshotProtectionService.shouldBlockForSession(
          authEntity: Right(malePhoneUser),
        ),
        isFalse,
      );
      expect(
        ScreenshotProtectionService.shouldBlockForSession(
          authEntity: Right(femalePhoneUser),
        ),
        isFalse,
      );
      expect(
        ScreenshotProtectionService.shouldBlockForSession(
          authEntity: Right(maleEmailUser),
        ),
        isFalse,
      );
      expect(
        ScreenshotProtectionService.shouldBlockForSession(
          authEntity: Right(femaleEmailUser),
        ),
        isFalse,
      );
    });

    test('blocks for normal users', () {
      final normalUser = UserEntity.empty().copyWith(
        phone: '9911223344',
        email: 'normal.user@gmail.com',
      );
      expect(
        ScreenshotProtectionService.shouldBlockForSession(
          authEntity: Right(normalUser),
        ),
        isTrue,
      );
    });
  });
}
