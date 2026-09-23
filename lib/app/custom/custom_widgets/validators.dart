import 'package:flutter/widgets.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

class Validators {
  static String? validateEmail(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.emailRequired(context);
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return AppLabels.invalidEmail(context);
    }
    return null;
  }

  //  validat password with 8 char, symbol, and number
  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.passwordRequired(context);
    }
    if (value.length < 8) {
      return AppLabels.passwordTooShort(context);
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppLabels.passwordUppercase(context);
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return AppLabels.passwordLowercase(context);
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppLabels.passwordNumber(context);
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppLabels.passwordSpecial(context);
    }
    return null;
  }

  static String? validateConfirmPassword(BuildContext context, String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppLabels.confirmPasswordRequired(context);
    }
    if (value != password) {
      return AppLabels.passwordsDoNotMatch(context);
    }
    return null;
  }

  static String? validateName(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.nameRequired(context);
    }
    if (value.length < 2) {
      return AppLabels.nameTooShort(context);
    }
    return null;
  }

  static String? validatePhoneNumber(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.phoneRequired(context);
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return AppLabels.invalidPhone(context);
    }
    return null;
  }

  static String? validateNotEmpty(BuildContext context, String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${AppLabels.isRequired(context)}';
    }
    return null;
  }

  static String? validateAge(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.ageRequired(context);
    }
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 100) {
      return AppLabels.invalidAge(context);
    }
    return null;
  }

  static String? validateNumber(BuildContext context, String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${AppLabels.isRequired(context)}';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName ${AppLabels.mustBeNumber(context)}';
    }
    return null;
  }

  static String? validatePinCode(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.pinCodeRequired(context);
    }
    final pinRegex = RegExp(r'^[0-9]{6}$');
    if (!pinRegex.hasMatch(value)) {
      return AppLabels.invalidPinCode(context);
    }
    return null;
  }

  // validete height in cm
  static String? validateHeight(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.heightRequired(context);
    }
    final height = int.tryParse(value);
    if (height == null || height < 30 || height > 250) {
      return AppLabels.invalidHeight(context);
    }
    return null;
  }

  // validat weight
  static String? validateWeight(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.weightRequired(context);
    }
    final weight = int.tryParse(value);
    if (weight == null || weight < 1 || weight > 300) {
      return AppLabels.invalidWeight(context);
    }
    return null;
  }

  static String? validateAadhar(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLabels.aadharRequired(context);
    }
    final aadharRegex = RegExp(r'^[0-9]{12}$');
    if (!aadharRegex.hasMatch(value)) {
      return AppLabels.invalidAadhar(context);
    }
    return null;
  }
}
