import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadi_milan/features/user/user_app/presentation/utils/profile_action_gate.dart';
import 'package:shadi_milan/features/user/user_app/presentation/widgets/complete_profile_bottom_sheet.dart';
import 'package:shadi_milan/features/user/user_app/presentation/widgets/sensitive_data_blur.dart';

void main() {
  group('ProfileActionGate.evaluate', () {
    test('requires profile completion when profile is incomplete and non-premium', () {
      expect(
        ProfileActionGate.evaluate(isProfileCreated: false, isPremium: false),
        ProfileGateResult.needsProfileCompletion,
      );
    });

    test('requires profile completion first even if premium flag is true', () {
      expect(
        ProfileActionGate.evaluate(isProfileCreated: false, isPremium: true),
        ProfileGateResult.needsProfileCompletion,
      );
    });

    test('requires premium plan once profile is completed', () {
      expect(
        ProfileActionGate.evaluate(isProfileCreated: true, isPremium: false),
        ProfileGateResult.needsPremium,
      );
    });

    test('allows Chat/Call only when profile is complete and premium is active', () {
      expect(
        ProfileActionGate.evaluate(isProfileCreated: true, isPremium: true),
        ProfileGateResult.allowed,
      );
    });
  });

  group('SensitiveDataBlur widget', () {
    testWidgets('hides real sensitive text and renders lock icon when locked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensitiveDataBlur(
              isUnlocked: false,
              maskedPlaceholder: '+91 ••••••••••',
              child: Text('9876543210'),
            ),
          ),
        ),
      );

      expect(find.text('9876543210'), findsNothing);
      expect(find.text('+91 ••••••••••'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('renders real sensitive text when unlocked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensitiveDataBlur(
              isUnlocked: true,
              maskedPlaceholder: '+91 ••••••••••',
              child: Text('9876543210'),
            ),
          ),
        ),
      );

      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text('+91 ••••••••••'), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });
  });

  group('CompleteProfileBottomSheet widget', () {
    testWidgets('displays 2-step guidance and CTA button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CompleteProfileBottomSheet(),
            ),
          ),
        ),
      );

      expect(find.text('Complete Your Profile First'), findsOneWidget);
      expect(find.text('Complete Your Profile'), findsOneWidget);
      expect(find.text('Choose a Premium Plan'), findsOneWidget);
      expect(find.text('COMPLETE YOUR PROFILE'), findsOneWidget);
    });
  });
}
