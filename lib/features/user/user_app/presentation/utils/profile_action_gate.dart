import 'package:flutter/material.dart';

import '../widgets/complete_profile_bottom_sheet.dart';
import '../widgets/premium_upgrade_bottom_sheet.dart';

enum ProfileGateResult {
  allowed,
  needsProfileCompletion,
  needsPremium,
}

/// Centralized 2-step gate enforcing:
/// 1) Profile must be completed (`isProfileCreated == true`), THEN
/// 2) Premium plan must be active (`isPremium == true`) for Chat & Call.
class ProfileActionGate {
  ProfileActionGate._();

  /// Pure decision helper for unit testing and consistent checks across screens.
  static ProfileGateResult evaluate({
    required bool isProfileCreated,
    required bool isPremium,
  }) {
    if (!isProfileCreated) {
      return ProfileGateResult.needsProfileCompletion;
    }
    if (!isPremium) {
      return ProfileGateResult.needsPremium;
    }
    return ProfileGateResult.allowed;
  }

  /// Checks whether the user can perform a contact action (Chat / Call / Contact Agent).
  /// Shows the appropriate bottom sheet if blocked and returns `false`.
  static bool ensureCanContact(
    BuildContext context, {
    required bool isProfileCreated,
    required bool isPremium,
    String? incompleteTitle,
    String? incompleteSubtitle,
  }) {
    final result = evaluate(
      isProfileCreated: isProfileCreated,
      isPremium: isPremium,
    );

    switch (result) {
      case ProfileGateResult.needsProfileCompletion:
        CompleteProfileBottomSheet.show(
          context,
          title: incompleteTitle,
          subtitle: incompleteSubtitle,
          showPremiumStep: true,
        );
        return false;

      case ProfileGateResult.needsPremium:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PremiumUpgradeBottomSheet(),
        );
        return false;

      case ProfileGateResult.allowed:
        return true;
    }
  }

  /// Checks whether the user has completed their profile before actions such as
  /// purchasing a Premium plan or viewing locked personal details.
  static bool ensureProfileComplete(
    BuildContext context, {
    required bool isProfileCreated,
    String? title,
    String? subtitle,
    bool showPremiumStep = true,
  }) {
    if (isProfileCreated) return true;

    CompleteProfileBottomSheet.show(
      context,
      title: title,
      subtitle: subtitle,
      showPremiumStep: showPremiumStep,
    );
    return false;
  }
}
