import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

import '../models/transliteration_response.dart';

class TransliterationService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  static Future<TransliterationResponse> transliterate(
    String text, {
    String targetLanguage = 'hi',
  }) async {
    debugPrint(
      "TransliterationService: Starting request for text: '$text' to '$targetLanguage'",
    );
    try {
      final callable = _functions.httpsCallable('transliterate');

      final response = await callable.call({
        "text": text,
        "targetLanguage": targetLanguage,
      });
      debugPrint("TransliterationService: Received response: ${response.data}");

      return TransliterationResponse.fromMap(response.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        "TransliterationService: FirebaseFunctionsException: ${e.code} - ${e.message}",
      );
      throw Exception(e.message ?? "Something went wrong");
    } catch (e) {
      debugPrint("TransliterationService: General Error: $e");
      throw Exception(e.toString());
    }
  }
}
