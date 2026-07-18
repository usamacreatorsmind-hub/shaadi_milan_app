import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// This helper provides a unified way to access localized strings
/// and can be extended to support live translation APIs.
extension L10nContextExtension on BuildContext {
  /// Quick access to localizations: context.l10n.someLabel
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

class L10nHelper {
  L10nHelper._();

  /// This is a template for a live translation helper.
  /// If you decide to use an API (like Google Translate), you would
  /// implement the network call here.
  static Future<String> translateLive(String text, String targetLanguage) async {
    // 1. Check if text is empty
    if (text.isEmpty) return '';

    // 2. Perform API call (example logic)
    // final response = await http.post('TRANSLATION_API_URL', body: {...});

    // For now, we return the original text as a placeholder
    return text;
  }
}
