import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final appTranslationServiceProvider = Provider<AppTranslationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppTranslationService(prefs);
});

final localeProvider = StateProvider<Locale>((ref) {
  final service = ref.watch(appTranslationServiceProvider);
  return service.getLocale();
});

class AppTranslationService {
  static const String _languageKey = 'selected_language_code';
  final SharedPreferences sharedPreferences;

  AppTranslationService(this.sharedPreferences);

  /// Saves the selected language code to local storage
  Future<void> setLanguageCode(String languageCode) async {
    await sharedPreferences.setString(_languageKey, languageCode);
  }

  /// Retrieves the saved language code, defaulting to 'en'
  String getLanguageCode() {
    return sharedPreferences.getString(_languageKey) ?? 'en';
  }

  /// Returns the Locale object based on the saved language
  Locale getLocale() {
    return Locale(getLanguageCode());
  }
}

class AppTranslation {
  final String languageCode;
  final String name;
  final String nativeName;

  const AppTranslation({
    required this.languageCode,
    required this.name,
    required this.nativeName,
  });

  static const List<AppTranslation> supportedTranslations = [
    AppTranslation(languageCode: 'en', name: 'English', nativeName: 'English'),
    AppTranslation(languageCode: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
  ];
}
