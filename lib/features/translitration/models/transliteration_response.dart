class TransliterationResponse {
  final String result;
  final bool cached;

  TransliterationResponse({required this.result, required this.cached});

  factory TransliterationResponse.fromMap(Map<dynamic, dynamic> json) {
    return TransliterationResponse(
      result: json['result'] ?? '',
      cached: json['cached'] ?? false,
    );
  }
}
