import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/transliteration_service.dart';

final transliterationProvider = Provider((ref) => TransliterationController());

final transliterationEnabledProvider = StateProvider<bool>((ref) => true);

class TransliterationController {
  Future<String> convert(String text, {String targetLanguage = 'hi'}) async {
    if (text.trim().isEmpty) {
      return "";
    }

    final response = await TransliterationService.transliterate(
      text,
      targetLanguage: targetLanguage,
    );

    return response.result;
  }
}
